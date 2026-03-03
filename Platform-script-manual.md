# INlib Platform Script Guide (Create a Script for a New Platform)

This guide explains how to create a **platform script** (a small JavaScript file) that plugs into **`INlib`** by defining `window.incoExternalVars`.
`INlib` then attaches DOM listeners (or sends immediately) and posts events such as `cart_add`, `order_add`, `login`, `register`, `cart_remove`, `logout`, etc.

---

## 1) What you deliver

For each new platform you create **one JS file** (e.g. `myplatform.js`) that:

1. Detects where it is (product page, cart, checkout, login…)
2. Fills `window.incoExternalVars` with event definitions
3. (Recommended for SPAs) calls `INlib.initExternalVars(window.incoExternalVars)` after setting it

**Important:** The platform script should only **collect + map data**.  
All sending is handled by `INlib`.

---

## 2) How INlib consumes your script (mental model)

`INlib.initExternalVars(exVar)` does roughly this:

- If you pass `exVar`, it becomes `window.incoExternalVars`
- For each key in `incoExternalVars`:
  - If `trigger.elm` exists → find element(s) and attach a listener (default event is `click`)
  - Otherwise → send the event immediately
- If an event has `validation`, it is stored and sent **later** when the validation rules match (typical: “clicked on checkout” → send on “thank you” page).

---

## 3) “Best template” example (cart_add + order_add + login + validation)

This example shows:
- `cart_add` (direct click/send)
- `order_add` (postponed send using `validation`)
- `login` (postponed send until the platform confirms login)

> File name suggestion: `myplatform.js`

```js
(function () {
  // 0) Ensure the global container exists
  window.incoExternalVars = (typeof window.incoExternalVars === 'undefined')
    ? {}
    : window.incoExternalVars;

  // Helper: optional, if you use INlib cookie-based contact id (incoK)
  function getContactIdFromCookie() {
    return (window.INlib && typeof window.INlib.getK === 'function' && INlib.getK())
      ? INlib.getK()
      : undefined;
  }

  /**
   * 1) CART ADD
   * Trigger: click on "Add to cart"
   * Payload: content.relatedId = product/variant ID
   */
  if (document.querySelector('form[action="/cart/add"]')) {
    window.incoExternalVars.cartAdd = {
      eventName: 'cart_add',

      trigger: {
        // If you omit trigger.event, INlib uses "click"
        elm: 'form[action="/cart/add"] *[name=add]'
      },

      // contactCols = contact matching priority (higher number = higher priority)
      // Example: try clientId first, then email, then id.
      contactCols: { email: 10, id: 1, clientId: 100 },

      contact: {
        // Example: platform customer id (replace for your platform)
        clientContactId: function () {
          return window.__st && __st.cid ? __st.cid.toString() : undefined;
        },
        contactId: function () {
          return getContactIdFromCookie();
        }
      },

      content: {
        relatedId: function () {
          // Example: Shopify variant input; replace with your platform’s product/variant id source
          var variantInput = document.querySelector('form[action="/cart/add"] input[name=id]');
          return variantInput ? variantInput.value : undefined;
        },
        idType: function () {
          return 'variantId';
        }
      }
    };
  }

  /**
   * 2) ORDER ADD (POSTPONED)
   * Trigger: user clicks "Checkout" / "Place order"
   * BUT: we only want to send after a successful order is confirmed (thank-you page).
   *
   * This uses validation:
   * - store the event at click time
   * - send later when page/url/func conditions match
   */
  if (document.querySelector('button.checkout, button.place-order, form[action*="checkout"]')) {
    window.incoExternalVars.orderAdd = {
      eventName: 'order_add',

      trigger: {
        elm: 'button.checkout, button.place-order'
      },

      contactCols: { email: 10, id: 1, clientId: 100 },
      contact: {
        email: 'input[name="email"], input[name="customer[email]"]',
        clientContactId: function () {
          return window.__st && __st.cid ? __st.cid.toString() : undefined;
        },
        contactId: function () {
          return getContactIdFromCookie();
        }
      },

      // At click time you usually DO NOT have the final order id yet → store minimal info now.
      content: {
        // Optional: store cart id / session id / checkout token if you have it
        checkoutToken: function () {
          return window.Shopify && Shopify.checkout ? Shopify.checkout.token : undefined;
        }
      },

      // Validation decides when to actually send.
      validation: {
        // 1) "thank you" URL check (regex)
        page: { regex: '/thank' },

        // 2) success indicator (function string evaluated later)
        // Replace with your platform’s success condition.
        func: "window.Shopify && Shopify.checkout && Shopify.checkout.order_id",

        // 3) enrich final payload at send time (string expressions evaluated later)
        content: {
          relatedId: "Shopify.checkout.order_id"
        }
      }
    };
  }

  /**
   * 3) LOGIN (POSTPONED)
   * Trigger: click on login submit
   * Send only after platform confirms a logged-in customer id
   */
  if (document.querySelector('form[action="/account/login"]')) {
    window.incoExternalVars.login = {
      eventName: 'login',
      trigger: { elm: 'form[action="/account/login"] button' },

      contactCols: { email: 10, id: 1, clientId: 100 },
      contact: {
        email: 'input[name="customer[email]"], input[name="email"]',
        contactId: function () {
          return getContactIdFromCookie();
        }
      },

      validation: {
        func: "__st && __st.cid",
        contact: {
          clientContactId: "__st && __st.cid ? (__st.cid.toString()) : undefined"
        }
      }
    };
  }

  // 4) SPA safety: (re)initialize immediately if INlib is already present
  if (window.INlib && typeof window.INlib.initExternalVars === 'function') {
    window.INlib.initExternalVars(window.incoExternalVars);
  }
})();
```

---

## 4) Testing / “dry-run” options (before sending to the server)

You have two practical ways to test:

### Test a single externalVar without sending (recommended)
`INlib` exposes:

```js
INlib.testExternalVars('cartAdd');
```

This processes the mapping the same way as sending, **but does not send to the server**.

Typical workflow:
1. Load your page with INlib + your platform script
2. Open DevTools Console
3. Run:
   ```js
   incoExternalVars.cartAdd && INlib.testExternalVars('cartAdd');
   ```
   
---

## 5) Naming conventions (recommended)

### Event keys (object keys)
Use readable camelCase keys:
- `cartAdd`
- `orderAdd`
- `login`
- `register`
- `cartRemove`
- `logout`
- `productView`
- `categoryView`

### `eventName` values (server event names)
Use stable snake_case names that your server expects:
- `cart_add`
- `order_add`
- `login`
- `register`
- `cart_remove`
- `logout`
- `product_view`
- `category_view` 

---

## 6) Reference: every supported property (explained)

This section describes the fields you can use inside `incoExternalVars.<key>`.

### 6.1 `eventName` / `eventNames`
**Required:** at least one of them must exist.
- `eventName: 'cart_add'` → send a single event type
- `eventNames: ['x', 'y']` → if your backend supports multiple names for one payload

### 6.2 `trigger`
Defines *when* INlib sends the event.

```js
trigger: {
  event: 'click',   // optional, default is "click"
  elm: '.selector'  // CSS selector OR function returning element(s)
}
```

**Notes**
- If `elm` matches multiple elements, INlib attaches a listener to each.
- If `trigger` is missing entirely → INlib sends immediately (useful for thank-you pages).

### 6.3 `contactCols` (IMPORTANT: Contact matching priority)

`contactCols` defines the weights for **contact identification and matching** on the server side. Since a single user may access from different devices or under different identifiers, Incomaker uses this scoring system to determine which existing contact to assign the event to (or whether to create a new one).

**How it works:**
1. Incomaker attempts to find all contacts in the database that match any of the provided identifiers (`email`, `clientId`, `personalId`, etc.).
2. If multiple potential matches are found, it uses `contactCols` to calculate a total score for each found contact.
3. For each field that matches exactly (including case sensitivity in some cases), it adds the weight (number) defined in `contactCols` to that contact.
4. The contact with the **highest total score** is selected as the "winner" (Best Match).

**Meaning of values:**
- **Higher number = higher trustworthiness/priority.** The more unique and reliable the identifier, the higher weight it should have.
- If you want the external system ID (e.g., ID from Shoptet or Shopify) to take precedence over the email, give it a higher weight.

**Example:**
```js
contactCols: { clientId: 100, email: 10, id: 1 }
```
- **`clientId` (mapped as `clientContactId` in JS):** Weight 100. This is usually the customer ID in your platform. It is very unique, hence it has the highest weight.
- **`email`:** Weight 10. Email is a good identifier, but it can change or be shared by multiple people (e.g., in a family).
- **`id` (internal Incomaker ID):** Weight 1. Lowest priority, used as a "last resort".

**Scenario:**
An event arrives with email `jan@novak.cz` and `clientId: "123"`.
- Contact A has email `jan@novak.cz`, but a different `clientId`. Score = **10**.
- Contact B has `clientId: "123"`, but a different email. Score = **100**.
- **Result:** The event will be attributed to Contact B because it has a higher score due to the `clientId` match.

**Available matching fields:**
- `email` (email address)
- `clientContactId` (stored as `clientId` in the database, your internal customer ID)
- `personalId` (national ID or other identifier)
- `phoneNumber1` (phone number)
- `id` (Incomaker contact UUID)

### 6.4 `contact`
Maps contact fields. These fields are used to create or update contact information.

#### Supported fields:
- `email`: Contact's email address.
- `clientContactId` (alias `clientId`): Your internal ID for the customer.
- `firstName`, `lastName`: Name components.
- `phoneNumber1`, `phoneNumber2`: Phone numbers.
- `personalId`: National ID or other identifier.
- `companyName`: Company name.
- `street`, `street2`, `city`, `zipCode`, `region`, `country`: Address components.
- `language`: Preferred language (ISO 2-letter code).
- `sex`: Gender (`M`, `F`).
- `birthday`: Date of birth.
- `customFields`: Object for any additional custom fields.
- `segmentMap`: Object for managing contact segments (tags). Keys are segment names, values are booleans (`true` to add, `false` to remove).
- `forcedSegmentMap`: Similar to `segmentMap`, but applied after other updates. Ensures the contact is in/out of specific segments regardless of other logic.

#### Mapping values:
Each value can be either:
1) **CSS selector** (input/select) → INlib reads `.value` (radio/checkbox supported)  
2) **Function** `(ev) => value` → `ev` is the DOM event (if triggered)
3) **Static value** → string or other primitive

Example:
```js
contact: {
  email: 'input[name="email"]',
  firstName: 'input[name="first_name"]',
  lastName: 'input[name="last_name"]',
  clientContactId: function () { return window.customer?.id?.toString(); },
  language: 'cs', // static value
  customFields: {
    loyalty_points: () => window.customer?.points,
    favorite_category: 'Electronics'
  },
  segmentMap: {
    "Newsletter": true,
    "VIP": () => window.customer?.isVip,
    "OldSegment": false
  },
  forcedSegmentMap: {
    "MandatoryGroup": true
  }
}
```

### 6.5 `content`
Maps content/context fields (product/order identifiers, URL, thumbnail, etc.).  
Used for tracking which product or category the user is interacting with.

#### Supported fields:
- `relatedId`: The primary identifier of the content (e.g., product SKU or ID).
- `idType`: Type of the `relatedId` (e.g., `variantId`, `clientId`).
- `caption`: Title of the product or page.
- `url`: Product or page URL.
- `contentThumbnailUrl`: Image URL.
- `price`, `priceVat`: Current price (with or without VAT).
- `currency`: Currency code (e.g., `CZK`, `EUR`).
- `priceDiscount`: Original price before discount.
- `categories`: Mapping of category names (e.g., `{ "1": "Electronics", "2": "Phones" }`).
- `tags`: Additional tags for the content.
- `meta`: Object for any additional metadata.

#### Mapping values:
Values can be selector, function, or static value.

Some fields get special handling:
- `url` → if selector, reads `href` attribute
- `contentThumbnailUrl` → if selector, reads `src` attribute

Example:
```js
content: {
  relatedId: () => window.product?.id,
  idType: 'variantId',
  caption: 'h1.product-title',
  price: () => window.product?.price,
  currency: 'CZK',
  url: 'link[rel="canonical"]',
  contentThumbnailUrl: 'meta[property="og:image"]'
}
```

### 6.6 `productOrder`
Use for order payload enrichment (line items etc.).  
Exact structure is up to your server; keep it consistent.

Example:
```js
productOrder: {
  itemsJson: () => JSON.stringify(window.order?.items || [])
}
```

### 6.7 `fieldsRequired`
Optional quick validation before sending.

Format:
```js
fieldsRequired: [
  { elm: 'input[name="email"]', regex: '^$' }
]
```

Meaning:
- INlib reads the input’s value
- `regex` is tested against the value
- if it **matches**, the field is considered **invalid** (so `'^$'` means “empty is invalid”)

### 6.8 `validation` (postpone sending until later)
If you add `validation`, INlib stores the event and sends later once validation passes.

You can combine these rules:

#### `validation.page`
Require URL match:
```js
validation: { page: { url: '/thank-you' } }
```
or regex:
```js
validation: { page: { regex: '/thank' } }
```

#### `validation.elm`
Require element presence/attribute/text:
```js
validation: {
  elm: { selector: '.success', attr: 'data-status', attrVal: 'ok', textVal: 'Thank you' }
}
```

#### `validation.func`
A **string expression** evaluated later (via `eval`):
```js
validation: { func: "window.order && order.id" }
```

#### `validation.contact` / `validation.content` / `validation.productOrder`
Fill additional fields later (string expressions):
```js
validation: {
  func: "window.order && order.id",
  content: { relatedId: "order.id" }
}
```

### 6.9 Segments (`segmentMap` & `forcedSegmentMap`)

Segments allow you to categorize contacts into groups (tags) directly from the script.

#### How it works:
- **`segmentMap`**: This is the standard way to manage segments. 
  - If a value is `true`, the contact is added to the segment.
  - If a value is `false`, the contact is removed from the segment.
- **`forcedSegmentMap`**: Works exactly like `segmentMap`, but is applied at the very end of the contact update process. Use this if you want to ensure a segment status is set regardless of other logic or defaults.

#### Example:
```js
contact: {
  email: 'input[name="email"]',
  segmentMap: {
    "Newsletter": true,        // Add to "Newsletter" segment
    "Waitlist": false,         // Remove from "Waitlist" segment
    "Premium": function() {     // Conditional addition
        return window.user?.isPremium; 
    }
  }
}
```

### 6.10 Custom Fields (`customFields`)

Custom fields allow you to store any additional information about the contact that is not covered by the standard fields.

#### How it works:
- You provide an object where keys are the field names in Incomaker and values are the data you want to store.
- If a custom field doesn't exist in your account, Incomaker will automatically create it.
- Values can be strings, numbers, or dates (formatted as strings).

#### Example:
```js
contact: {
  email: 'input[name="email"]',
  customFields: {
    internal_id: () => window.user?.internalId,
    shoe_size: 42,
    registration_source: "web_footer_form"
  }
}
```

---

## 7) Deployment: how developers should deliver the script

Developers **can** embed the platform script directly into the page (or include it as a static asset).

However, the preferred approach is:
- **send the script to `vach@incomaker.com`** (so it can be hosted/managed centrally),
- and then load it from there (consistent versioning, faster hotfixes, easier rollout across clients).

Recommended rollout workflow:
1. Developer creates `myplatform.js`
2. Developer tests locally using `INlib.testExternalVars(...)` / `?isTest=true`
3. Script is delivered to your team / uploaded to `incomaker.com`
4. Production sites load the hosted version

---

## 8) Shipping checklist

- [ ] `cart_add` fires once per action
- [ ] `order_add` uses `validation` and sends only after success (thank-you)
- [ ] `login` waits for a real successful login (validation.func)
- [ ] No console errors
- [ ] Works on mobile + desktop
- [ ] Works in SPA route changes (re-run `INlib.initExternalVars(...)`)
