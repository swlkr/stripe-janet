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
(stripe/customers/retrieve "cus_123456789")

; # create a customer
(stripe/customers/create {:name "name"})

; # update a customer
(stripe/customers/update "cus_123456789" {:name "name"})

; # delete a customer
(stripe/customers/delete "cus_123456789")
```

There's also an alternative way to use the library that's similar to the "raw request" option in the [stripe cli](https://stripe.com/docs/stripe-cli)

```clojure
(import stripe)
(import stripe/urls :prefix "")

(stripe/api-key "sk_test_...")

; # list customers
(stripe/GET customers)

; # get single product
(stripe/GET customers/:id "cus_123456789")

; # create a product
(stripe/POST products {:name "name" :description "description"})

; # delete a product
(stripe/DELETE products/:id "prod_123456789")

; # update a product
(stripe/POST products/:id "prod_123456789" {:name "new name"})
```

Pick the one that's best suited to your tastes

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
