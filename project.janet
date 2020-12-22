(declare-project
  :name "stripe"
  :description "A stripe client library for janet"
  :dependencies ["https://github.com/joy-framework/http"
                 "https://github.com/joy-framework/codec"
                 "https://github.com/janet-lang/json"]
  :author "Sean Walker"
  :license "MIT"
  :url "https://github.com/swlkr/stripe-janet"
  :repo "git+https://github.com/swlkr/stripe-janet")

(declare-source
  :source @["src/stripe" "src/stripe.janet"])
