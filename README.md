# Stripe Janet Library

Use stripe from janet hassle free!

- Create stripe objects!
- Verify webhooks!
- Easy parameter serialization!

## Install

```sh
jpm install https://github.com/swlkr/stripe-janet
# or add it as a dependency in your project.janet
# {:dependencies ["https://github.com/swlkr/stripe-janet"]}
```

## Usage

```clojure
(import stripe)

(stripe/api-key "sk_test_...")

; # list customers
(stripe/customers/list)

; # get single customer
(stripe/customers/find "cus_123456789")
```

There's also an alternative way to use the library:

Pick the one that's best suited to your tastes

```clojure
(import stripe)
(import stripe/urls :prefix "")

(stripe/api-key "sk_test_...")

; # list customers
(stripe/GET customers)

; # get single customer
(stripe/GET customers/:id "cus_123456789")

; # create a product
(stripe/POST products {:name "name" :description "description"})
```

### Configure API Version

```clojure
(stripe/api-version "2018-02-28")
```

### Set the log level for more info

There are two log levels: `info` and `debug`

`info` is good for production, `debug` is good for development

```clojure
(stripe/log-level stripe/LOG_LEVEL_INFO)
```
