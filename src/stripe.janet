(import http)
(import json)
(import codec)
(import jhydro)


(def LOG_LEVEL_INFO "info")
(def LOG_LEVEL_DEBUG "debug")
(def HOST "https://api.stripe.com/v1/")


(var *api-key* nil)
(var *api-version* "2020-08-27")
(var *log-level* LOG_LEVEL_INFO)


(defn api-key [str]
  (set *api-key* str))


(defn api-version [str]
  (set *api-version* str))


(defn log-level [str]
  (set *log-level* str))


(defn- url/join [& strs]
  (-> (map |(string/trim $ "/") strs)
      (string/join "/")))


(defn- flatten-dictionary [dictionary]
  (var output @{})

  (eachp [k v] dictionary
    (if (not (indexed? v))
      (put output k v)

      (do
        (var i 0)

        (eachp [x y] v
          (if (dictionary? y)
            (eachp [a b] y
              (put output (string k "[" x "][" a "]") b))
            (put output (string k "[" x "]") y))

          (++ i)))))

  output)


(defn- form-encode [dictionary]
  (-> dictionary flatten-dictionary http/form-encode))


(defn- check-api-key []
  (unless *api-key*
    (error "Please set the api-key with (stripe/api-key \"sk_test_...\") before calling the api")))


(defn- absolute-url [str params]
  (as-> (string/replace-all "/:id" "/%s" str) ?
        (string/format ? (map string params))
        (url/join HOST ?)))


(defn- log-request [method url &opt body]
  (when (= "debug" *log-level*)
    (print "Sending " method " " url)

    (when body
      (print)
      (print body))))


(defn- log-response [response]
  (when (= "debug" *log-level*)
    (print "Received " (get response :status))

    (eachp [k v] (get response :headers)
      (print k ": " v))

    (print)

    (string/format "%q" (get response :body))))


(defn- response [res]
  (log-response res)

  (let [{:status status :body body} res
        body (json/decode body true true)]
    (if (= 200 status)
      body
      (error body))))


(defn GET [url & params]
  (check-api-key)

  (let [abs-url (absolute-url url params)]
    (log-request "GET" abs-url)
    (-> (http/get abs-url :username *api-key*)
        (response))))


(defn POST [url body & params]
  (check-api-key)

  (let [abs-url (absolute-url url params)
        encoded-body (form-encode body)]
    (log-request "POST" abs-url encoded-body)
    (-> (http/post abs-url encoded-body
                   :username *api-key*)
        (response))))


(defn DELETE [url & params]
  (check-api-key)

  (let [abs-url (absolute-url url params)]
    (log-request "DELETE" abs-url)
    (-> (http/delete abs-url :username *api-key*)
        (response))))


# errors
(def json/parser-error :json/parser-error)
(def signature-verification-error :stripe/signature-verification-error)
(def webhook-tolerance-error :stripe/webhook-tolerance-error)


# webhooks
(def- TOLERANCE 500)


(defn signature [secret timestamp body]
  (let [payload (string timestamp "." body)]
    (codec/hmac/sha256 secret payload)))


(defn webhook-event [secret body header &opt tolerance]
  (default tolerance TOLERANCE)

  (let [data (as-> (string/split "," header) ?
                   (mapcat |(string/split "=" $) ?)
                   (struct ;?))
        timestamp (scan-number (get data "t"))
        expected-signature (get data "v1")
        signature (signature secret timestamp body)]

    (unless (jhydro/util/= expected-signature signature)
      (error {:type signature-verification-error})
      (break))

    (if (< timestamp (- (os/time) tolerance))
      (error {:type webhook-tolerance-error})
      (json/decode body true true))))


# checkouts
(def checkout/sessions/create (partial POST "/checkout/sessions"))
(def checkout/sessions (partial GET "/checkout/sessions"))
(def checkout/session (partial GET "/checkout/sessions/:id"))
(def checkout/session/line-items (partial GET "checkout/sessions/:id/line_items"))


# CRUD
(each object '[products prices customers]
  (each action '[list create update delete retrieve]
    (let [sym (symbol object "/" action)]
      (case action
        'list
        (defglobal sym
                   (partial GET (string "/" object)))

        'find
        (defglobal sym
                   (partial GET (string "/" object "/:id")))

        'create
        (defglobal sym
                   (partial GET (string "/" object)))

        'update
        (defglobal sym
                   (fn [id body]
                     (POST (string "/" object "/:id")
                           body id)))

        'delete
        (defglobal sym
                   (partial DELETE (string "/" object "/:id")))))))
