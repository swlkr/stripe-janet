(def- urls '[checkout/sessions
             checkout/sessions/:id
             checkout/sessions/:id/line_items
             prices
             prices/:id
             products
             products/:id
             customers
             customers/:id])

(each url urls
  (defglobal url (string url)))
