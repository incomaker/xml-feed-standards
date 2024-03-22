# Incomaker XML Feed Standards

This repository contains documentation for implementation of Incomaker XML feeds,
XSD files for [schema validation](#xml-feed-validation) and examples.

Instead of painstaking integration of full API and passing all data through the calls,
just provide Incomaker with the following data. Incomaker will regularly download data from the shop, usually once per day.

You should create the following data feeds:

- [Categories](#categories)
- [Products](#products)
- [Contacts](#contacts)
- [Orders](#orders)
- [Coupons](#coupons)
- [Info](#info)

## Submitting the Base URL

### Feed Base URL

All feeds should be available at the **Base URL** specified at the plugin registration.
The expected URL with parameters that will be called from Incomaker could look like the following:

    https://www.myeshop.com/feed.php?key=86342b04-fa97-4fde-baa5-c3f912b88430&type=product

Everything before `?` sign is a **Base URL** (in this example: `https://www.myeshop.com/feed.php`),
everything after it are parameters that will be added by Incomaker when downloading your feed.

You will have to provide Incomaker with your **Base URL**.

Please, see the full list of parameters to implement below.

### Feed Parameters

| Param Name        | Required     | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                                              |
|-------------------|--------------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **key**           | **required** | [string](#string)   | API key returned from the register plugin function. API key has a format of [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)                                                                                                                                                                                                                                                                          |
| **type**          | **required** | [string](#string)   | Indicates type of returned feed. Supported values are: **category**, **product**, **contact**, **order** or **coupon**.                                                                                                                                                                                                                                                                                                  |
| **id**            | optional     | [string](#string)   | An internal identifier of an item to be returned. If the request with this parameters is called, Incomaker expects to receive one item (i.e. one product) with the respective ID. The ID is the internal ID of the eshop. Id has the highest priority. If it is used in the call together with since, limit, or offset, ID is the only parameter to follow.                                                              |
| **since**         | optional     | [date](#date)       | When the request is called with **since** parameter, it is expected to return just the changes made since the respective date (inclusive). If it is technically impossible to implement it, you can always return the full list of items, and Incomaker distinguish the changes automatically. However, it is **strongly recommended** to implement it in order to save traffic and server load on both sides.  |
| **limit**         | optional     | [integer](#integer) | Maximum number of items that should be returned in the call. Incomaker always tries to request the items in batches of reasonable sizes, however it is recommended to limit the maximum number of returned items for the security reasons. Optionally could be used together with **offset**.                                                                                                                            |
| **offset**        | optional     | [integer](#integer) | First item that will be returned in the requested batch. Can be used together with **limit** only.                                                                                                                                                                                                                                                                                                                       |
| **downloadCount** | optional     | [integer](#integer) | Only relevant for **type=coupon**. Indicates the number of coupons to be generated.                                                                                                                                                                                                                                                                                                                                      |

## Feed Data Structure

Incomaker expects the feeds provided by the e-shop in the following formats. Most of the fields are optional, however you should provide as much as possible.
The intelligence of Incomaker is dependent on data available, and the more data we have the better results we deliver.

In all cases, the root element (products, orders, etc.) can contain an optional attribute **totalItems** containing the total number of filtered items of the current entity.
It means all the available entities after filtering (applied *since* date) before applying pagination (*limit* and *offset*).

XML structure definition is bellow, for each feed, a link to XSD schema file is enclosed.

### Common Data Types

#### String

Any sequence of characters.

Please note that encoding must match with that in your XML header, we strongly recommend using **UTF-8** encoding for all XML files.

Also make sure that string doesn't contain any characters prohibited inside XML like `&`, `#`, `$`, etc.
If you need to include them in your string, please use [CDATA](https://en.wikipedia.org/wiki/CDATA).

#### Decimal

Decimal number with dot (`.`) used as decimal separator. Number should not contain spaces or any thousands separator.

#### Integer

Whole number without any decimal or thousands separator.

#### Date

Date without time formatted in ISO date format - **YYYY-MM-DD** (example: `2023-06-24`)

#### Datetime

Date and time formatted in ISO datetime format - **YYYY-MM-DD'T'HH:mm:ss** (example: `2023-06-24T13:00:24`)

Optionally, datetime can also include a time zone (example: `2023-06-24T13:00:24+02:00`).
When datetime value doesn't contain timezone, one you entered during plugin registration will be used.

#### CustomFields

A map of custom fields where any related value can be stored.
Used for adding extra information not covered by standard fields.

##### CustomField

Root element tag: **f**

| Attribute Name | Required     | Type              | Description                        |
|----------------|--------------|-------------------|------------------------------------|
| **key**        | **required** | [string](#string) | Name of custom field               |

##### Example

```xml
<customFields>
    <f key="ShoeSize">L</f>
    <f key="EyeColor">blue</f>
</customFields>
```

#### GroupedCustomFields

A map of custom fields where any related value can be stored. In contract with *CustomFields*, these can additionally be assigned a group.

##### GroupedCustomField

Root element tag: **f**

| Attribute Name | Required     | Type              | Description                        |
|----------------|--------------|-------------------|------------------------------------|
| **key**        | **required** | [string](#string) | Name of custom field               |
| **group**      | optional     | [string](#string) | Logical grouping of related fields |

##### Example

```xml
<customFields>
    <f key="ShoeSize" group="trait">L</f>
    <f key="EyeColor" group="trait">blue</f>
</customFields>
```

#### Tags

A set of simple tags.

##### Example

```xml
<tags>
    <t>Apollo Program</t>
    <t>Astronaut</t>
</tags>
```

### Categories

Collection of product categories.

Root element tag: **categories**

#### Category

Root element tag: **c**

| Attribute Name | Required     | Type              | Description                                                                                   |
|----------------|--------------|-------------------|-----------------------------------------------------------------------------------------------|
| **id**         | **required** | [string](#string) | An internal category identifier. This Id must match with the Id used in Products and Orders.  |

| Element Name         | Required     | Type                                      | Description                                             |
|----------------------|--------------|-------------------------------------------|---------------------------------------------------------|
| **parentCategoryId** | optional     | [string](#string)                         | An internal category identifier of the parent category. |
| **languages**        | **required** | [CategoryLanguages](#categorylanguages)   | Category names in different languages.                  |

#### CategoryLanguages

Caption and links for the individual languages.

Root element tag: **languages**

##### CategoryLanguage

Root element tag: **l**

| Attribute Name | Required     | Type              | Description                                                                                                                                                   |
|----------------|--------------|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **id**         | **required** | [string](#string) | ISO code of the language is preferred (e.g. **en**). IETF language tag (e.g. **en-US**) could be also used, but anything from the third character is ignored. |

| Element Name | Required     | Type              | Description                             |
|--------------|--------------|-------------------|-----------------------------------------|
| **name**     | **required** | [string](#string) | Name of the category in given language. |
| **url**      | optional     | [string](#string) | URL of category page in given language. |

#### Example

```xml
<?xml version="1.0" encoding="utf-8"?>
<categories
    version="2.15"
    totalItems="2"
>
    <c id="1">
        <languages>
            <l id="en">
                <name>Rockets</name>
            </l>
        </languages>
    </c>
    <c id="2">
        <parentCategoryId>1</parentCategoryId>
        <languages>
            <l id="en">
                <name>Saturn 5</name>
                <url>https://myshop.com/saturn-5</url>
            </l>
        </languages>
    </c>
</categories>
```

### Products

Products provide detailed product information. This is the most complex feed.

Collection of products. Root element tag: **products**

#### ProductCategories

The list of the category IDs, where the product is present.

#### Example

```xml
<categories>
    <c>1</c>
    <c>12</c>
</categories>
```

#### ProductPrices

List of product prices.

| Attribute Name | Required | Type              | Description                           |
|----------------|----------|-------------------|---------------------------------------|
| **currency**   | optional | [string](#string) | An Id of the variant of the product.. |
| **pricelist**  | optional | [string](#string) | Name of the pricelist.                |


| Element Name           | Required     | Type                | Description                                                                                                                                                               |
|------------------------|--------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **amount**             | **required** | [decimal](#decimal) | Base price of the products (typically tax inclusive).                                                                                                                     |
| **priceAfterDiscount** | optional     | [decimal](#decimal) | Reduced price if there is a discount (the same regime as in the amount element, i.e. tax inclusive). If there is no reduction on this item, don’t use the element at all. |
| **priceWithoutTax**    | optional     | [decimal](#decimal) | Price without tax (VAT or sales tax).                                                                                                                                     |
| **discountRate**       | optional     | [decimal](#decimal) | Percentual discount rate.                                                                                                                                                 |

#### Example

```xml
<prices>
    <p currency="USD" pricelist="cenik1">
        <amount>129</amount>
        <priceWithoutTax>111</priceWithoutTax>
        <priceAfterDiscount>99</priceAfterDiscount>
        <discountRate>15</discountRate>
    </p>
</prices>
```

#### ProductLanguages

Product strings in different languages.

Root element tag: **languages**

##### ProductLanguageAttributes

A map of language-specific custom attributes.

Root element tag: **attributes**

###### ProductLanguageAttribute

Custom product language-specific attribute. Tag content represents attribute value.

Root element tag: **a**

| Attribute Name | Required     | Type              | Description                    |
|----------------|--------------|-------------------|--------------------------------|
| **key**        | **required** | [string](#string) | Machine name of the attribute. |

##### ProductLanguage

Root element tag: **l**

| Attribute Name | Required     | Type              | Description                                                                                                                                                   |
|----------------|--------------|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **id**         | **required** | [string](#string) | ISO code of the language is preferred (e.g. **en**). IETF language tag (e.g. **en-US**) could be also used, but anything from the third character is ignored. |

| Element Name         | Required     | Type                                                    | Description                                           |
|----------------------|--------------|---------------------------------------------------------|-------------------------------------------------------|
| **name**             | **required** | [string](#string)                                       | Name of the product in given language.                |
| **description**      | optional     | [string](#string)                                       | Product description in the particular language.       |
| **shortDescription** | optional     | [string](#string)                                       | Product short description in the particular language. |
| **url**              | **required** | [string](#string)                                       | A URL of the product in the given language.           |
| **attributes**       | optional     | [ProductLanguageAttributes](#productlanguageattributes) | A map of language-specific custom attributes.         |

#### RelatedProducts

A set of productIds of similar/related products.

#### Example

```xml
<related>
    <r>1001001</r>
    <r>2305001</r>
</related>
```

#### Product Variant

Represents a single product variant.

Root element tag: **p**

| Attribute Name | Required     | Type              | Description                          |
|----------------|--------------|-------------------|--------------------------------------|
| **id**         | **required** | [string](#string) | An Id of the variant of the product. |

| Element Name        | Required     | Type                                    | Description                                                                                                                                   |
|---------------------|--------------|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| **imageUrl**        | optional     | [string](#string)                       | URL of image of the product.                                                                                                                  |
| **categories**      | optional     | [ProductCategories](#productcategories) | The list of the category IDs, where the product is present.                                                                                   |
| **prices**          | **required** | [ProductPrices](#productprices)         | List of product prices in different currencies.                                                                                               |
| **purchase**        | optional     | [decimal](#decimal)                     | Purchase price of the stock. Purchase price of the stock. In an optional attribute **currency**, you can set the currency of the price.       |
| **tags**            | optional     | [Tags](#tags)                           | Product tags.                                                                                                                                 |
| **tax**             | optional     | [decimal](#decimal)                     | Tax in form of decimal number (e.g. 1.21 for tax of 21%)                                                                                      |
| **unit**            | optional     | [string](#string)                       | The name of the unit.                                                                                                                         |
| **brand**           | optional     | [string](#string)                       | Brand name.                                                                                                                                   |
| **ean**             | optional     | [string](#string)                       | EAN code                                                                                                                                      |
| **condition**       | optional     | [string](#string)                       | The condition of the product. The possible values are: **new**, **unwrapped**, **used**, **damaged**, **defunct**, **refurbished**, **other** |
| **stock**           | optional     | [integer](#integer)                     | The number of the items on hand.                                                                                                              |
| **active**          | optional     | [integer](#integer)                     | The product is active (**0** - no, **1** - yes).                                                                                              |
| **productId**       | optional     | [string](#string)                       | If this item is a variant, then this is an Id of the parent product.                                                                          |
| **newFlag**         | optional     | [integer](#integer)                     | The product is flagged new (**0** - no, **1** - yes).                                                                                         |
| **specialDealFlag** | optional     | [integer](#integer)                     | The product is flagged a special deal (**0** - no, **1** - yes).                                                                              |
| **choiceFlag**      | optional     | [integer](#integer)                     | The product is flagged a choice - recommended product (**0** - no, **1** - yes).                                                              |
| **added**           | optional     | [datetime](#datetime)                   | When the product was added to e-shop.                                                                                                         |
| **updated**         | optional     | [datetime](#datetime)                   | When the product was updated for the last time.                                                                                               |
| **availability**    | optional     | [integer](#integer)                     | The number of days to deliver the product. 0 means immediately.                                                                               |
| **languages**       | **required** | [ProductLanguages](#productlanguages)   | Product strings in different languages.                                                                                                       |
| **related**         | optional     | [RelatedProducts](#relatedproducts)     | A set of productIds of similar/related products.                                                                                              |
| **customFields**    | optional     | [CustomFields](#customfields)           | A map of custom fields where any product-related value can be stored.                                                                         |

#### Example

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<products
    version="2.16"
    totalItems="123"
>
    <p id="P257">
        <productId>101834</productId>
        <active>1</active>
        <ean>85941691750107</ean>
        <imageUrl>https://images.books.com/space-program.jpg</imageUrl>
        <categories>
            <c>1</c>
            <c>2</c>
            <c>23</c>
        </categories>
        <prices>
            <p currency="USD">
                <amount>129</amount>
                <priceWithoutTax>111</priceWithoutTax>
                <priceAfterDiscount>99</priceAfterDiscount>
            </p>
            <p currency="CZK">
                <amount>2500</amount>
            </p>
        </prices>
        <purchase currency="USD">21</purchase>
        <tax>1.21</tax>
        <unit>pcs</unit>
        <brand>NASA</brand>
        <availability>10</availability>
        <condition>new</condition>
        <stock>155</stock>
        <newFlag>0</newFlag>
        <specialDealFlag>0</specialDealFlag>
        <choiceFlag>0</choiceFlag>
        <added>2023-06-24T08:24:21</added>
        <updated>2023-06-24T13:00:24</updated>
        <languages>
            <l id="cs">
                <name>Space Program</name>
                <description>
                    Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam egestas wisi a erat. Phasellus enim erat, vestibulum vel, aliquam a, posuere eu, velit. In sem justo, commodo ut, suscipit at, pharetra vitae, orci. Maecenas ipsum velit, consectetuer eu lobortis ut, dictum at dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? Nullam justo enim, consectetuer nec, ullamcorper ac, vestibulum in, elit. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Fusce tellus. Nullam eget nisl. Curabitur ligula sapien, pulvinar a vestibulum quis, facilisis vel sapien. Etiam egestas wisi a erat. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Proin pede metus, vulputate nec, fermentum fringilla, vehicula vitae, justo. Aliquam erat volutpat. Nullam eget nisl. Donec ipsum massa, ullamcorper in, auctor et, scelerisque sed, est. Duis ante orci, molestie vitae vehicula venenatis, tincidunt ac pede.
                </description>
                <url>https://www.books.com/educational/space-program</url>
                <attributes>
                    <a key="Velikost">L</a>
                    <a key="Barva">Modrá</a>
                </attributes>
            </l>
        </languages>
        <customFields>
            <f key="Size">L</f>
            <f key="Color">blue</f>
        </customFields>
        <tags>
            <t>Apollo Program</t>
            <t>Astronaut</t>
        </tags>
    </p>
</products>
```

### Contacts

Collection of e-shop customers.

Root element tag: **contacts**

#### Contact

Root element tag: **c**

| Attribute Name | Required     | Type              | Description                         |
|----------------|--------------|-------------------|-------------------------------------|
| **id**         | **required** | [string](#string) | An Id of the contact in the e-shop  |

| Element Name     | Required | Type                                        | Description                                                       |
|------------------|----------|---------------------------------------------|-------------------------------------------------------------------|
| **firstName**    | optional | [string](#string)                           |                                                                   |
| **lastName**     | optional | [string](#string)                           |                                                                   |
| **sex**          | optional | [string](#string)                           | Possible values: **MALE**, **FEMALE** or **UNKNOWN**              |
| **email**        | optional | [string](#string)                           |                                                                   |
| **language**     | optional | [string](#string)                           | The language code (ISO 639-1, e.g. en)                            |
| **birthday**     | optional | [date](#date)                               |                                                                   |
| **consentDate**  | optional | [datetime](#datetime)                       | GDPR consent date                                                 |
| **consentTitle** | optional | [string](#string)                           | GDPR consent title                                                |
| **web**          | optional | [string](#string)                           |                                                                   |
| **remarks**      | optional | [string](#string)                           |                                                                   |
| **street**       | optional | [string](#string)                           |                                                                   |
| **street2**      | optional | [string](#string)                           |                                                                   |
| **city**         | optional | [string](#string)                           |                                                                   |
| **zipCode**      | optional | [string](#string)                           |                                                                   |
| **phoneNumber1** | optional | [string](#string)                           |                                                                   |
| **phoneNumber2** | optional | [string](#string)                           |                                                                   |
| **country**      | optional | [string](#string)                           | ISO country code (two letters)                                    |
| **newsletter**   | optional | [integer](#integer)                         | Is customer subscribed to a newsletter? (**0** - no, **1** - yes) |
| **currency**     | optional | [string](#string)                           | Customer’s default currency                                       |
| **pricelist**    | optional | [string](#string)                           | Customer’s default pricelist                                      |
| **tags**         | optional | [Tags](#tags)                               |                                                                   |
| **customFields** | optional | [GroupedCustomFields](#groupedcustomfields) |                                                                   |

#### Example

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<contacts
    version="2.15"
    totalItems="6040"
>
    <c id="e28bc2f0">
        <email>neil.armstrong@nasa.gov</email>
        <sex>MALE</sex>
        <firstName>Neil</firstName>
        <lastName>Armstrong</lastName>
        <street>Crater Road</street>
        <street2>2nd floor</street2>
        <city>Moon City</city>
        <zipCode>79401</zipCode>
        <phoneNumber1>0102030405</phoneNumber1>
        <phoneNumber2/>
        <language>en</language>
        <country>US</country>
        <companyName>NASA</companyName>
        <birthday>1930-08-05</birthday>
        <consentDate>2069-07-24T16:50:35</consentDate>
        <consentTitle>Fake Moon Landing Non-Disclosure Agreement</consentTitle>
        <web>http://nasa.gov</web>
        <remarks/>
        <newsletter>1</newsletter>
        <currency>USD</currency>
        <pricelist>pricelist1</pricelist>
        <tags>
            <t>Apollo Program</t>
            <t>Astronaut</t>
        </tags>
        <customFields>
            <f key="ShoeSize" group="trait">L</f>
            <f key="EyeColor" group="trait">blue</f>
        </customFields>
    </c>
</contacts>
```

Validate with [XML Schema Definition](xsd/contacts.xsd).

### Orders

List of the orders.

#### OrderContact

Contact details in case of unregistered sale.
There must be either **contactId** or **contact** specified. Only one of the elements is allowed!

Root element tag: **contact**

| Attribute Name | Required     | Type              | Description                        |
|----------------|--------------|-------------------|------------------------------------|
| **id**         | **required** | [string](#string) | An Id of the order in the e-shop.  |

| Element Name     | Required | Type              | Description                     |
|------------------|----------|-------------------|---------------------------------|
| **firstName**    | optional | [string](#string) |                                 |
| **lastName**     | optional | [string](#string) |                                 |
| **email**        | optional | [string](#string) |                                 |
| **street**       | optional | [string](#string) |                                 |
| **street2**      | optional | [string](#string) |                                 |
| **city**         | optional | [string](#string) |                                 |
| **zipCode**      | optional | [string](#string) |                                 |
| **phoneNumber1** | optional | [string](#string) |                                 |
| **phoneNumber2** | optional | [string](#string) |                                 |
| **country**      | optional | [string](#string) | ISO country code (two letters)  |
| **language**     | optional | [string](#string) | ISO language code (two letters) |

#### OrderItems

List of order items.

##### Order Item

Root element tag: **i**

| Attribute Name | Required     | Type              | Description                                                       |
|----------------|--------------|-------------------|-------------------------------------------------------------------|
| **id**         | **required** | [string](#string) | An Id of product variant. Should match **id** in *Products* feed. |

| Element Name        | Required     | Type                | Description                           |
|---------------------|--------------|---------------------|---------------------------------------|
| **quantity**        | **required** | [decimal](#decimal) | The quantity of goods sold.           |
| **price**           | **required** | [decimal](#decimal) | The price of the item. Tax inclusive. |
| **priceWithoutTax** | optional     | [decimal](#decimal) | The price of the item without tax.    |

#### Order

Root element tag: **o**

| Attribute Name | Required     | Type              | Description                        |
|----------------|--------------|-------------------|------------------------------------|
| **id**         | **required** | [string](#string) | An Id of the order in the e-shop.  |

| Element Name        | Required     | Type                          | Description                                                                            |
|---------------------|--------------|-------------------------------|----------------------------------------------------------------------------------------|
| **contactId**       | optional     | [string](#string)             | An Id of the contact in the e-shop. (Use only when **contact** is missing)             |
| **contact**         | optional     | [OrderContact](#ordercontact) | Contact details in case of unregistered sale. (Use only when **contactId** is missing) |
| **created**         | optional     | [datetime](#datetime)         | The timestamp of creation.                                                             |
| **finished**        | optional     | [datetime](#datetime)         | The timestamp of the moment when the order is finished.                                |
| **total**           | optional     | [decimal](#decimal)           | Total price of the order including shipping, discounts, etc.                           |
| **totalWithoutTax** | optional     | [decimal](#decimal)           | Total price of the order including shipping, discounts, etc. - tax exclusive.          |
| **currency**        | optional     | [string](#string)             | Order currency.                                                                        |
| **payment**         | optional     | [string](#string)             | The means of payment.                                                                  |
| **state**           | optional     | [string](#string)             | The state of the order.                                                                |
| **items**           | **required** | [OrderItems](#orderitems)     | The list of the items in the order.                                                    |

#### Example

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<orders
    version="2.15"
    totalItems="10"
>
    <o id="88886">
        <contact>
            <email>neil.armstrong@nasa.gov</email>
            <firstName>Neil</firstName>
            <lastName>Armstrong</lastName>
            <phoneNumber1>0102030405</phoneNumber1>
            <city>Moon City</city>
            <country>US</country>
            <street>Crater Road</street>
            <language>en</language>
            <zipCode>79401</zipCode>
        </contact>
        <created>1969-06-24T16:19:22</created>
        <finished>1969-06-24T18:20:05</finished>
        <payment>credit card</payment>
        <total>284</total>
        <totalWithoutTax>234.71074388429753</totalWithoutTax>
        <currency>USD</currency>
        <items>
            <i id="111836">
                <quantity>1</quantity>
                <price currency="EUR">199</price>
                <priceWithoutTax>164.46281</priceWithoutTax>
                <currency>CZK</currency>
            </i>
        </items>
    </o>
</orders>
```

### Coupons

#### CouponValues

List of actual coupon codes. Element value is code of the coupon.

##### Example

| Attribute Name | Required     | Type              | Description                                                                                           |
|----------------|--------------|-------------------|-------------------------------------------------------------------------------------------------------|
| **contactId**  | **optional** | [string](#string) | Coupon recipient. An Id of the contact in the e-shop, must math **id** attribute in the contact feed. |

```xml
<values>
    <v contactId="646GS">ABSCDF</v>
    <v>GHCJKD</v>
    <v>D45s45</v>
</values>
```

#### Coupon

Root element tag: **c**

| Attribute Name | Required     | Type              | Description                                        |
|----------------|--------------|-------------------|----------------------------------------------------|
| **id**         | **required** | [string](#string) | An Id of the coupon type (template) in the e-shop. |

| Element Name     | Required     | Type                          | Description                                                                                                                                                                                                                        |
|------------------|--------------|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **reusable**     | **required** | [integer](#integer)           | Whether this type of coupon can be used multiple times. **0** - no, **1** - yes. Reusable coupons are typically used as a single code for multiple users. Non-reusable coupon is usually personalized, and we can track its usage. |
| **discountType** | optional     | [string](#string)             | Possible values: **PERCENTUAL**, **MONETARY**                                                                                                                                                                                      |
| **discount**     | optional     | [decimal](#decimal)           | Either the monetary or percentual value of the coupon type.                                                                                                                                                                        |
| **validFrom**    | optional     | [datetime](#datetime)         |                                                                                                                                                                                                                                    |
| **validTo**      | optional     | [datetime](#datetime)         |                                                                                                                                                                                                                                    |
| **values**       | **required** | [CouponValues](#couponvalues) | The list of actual coupon codes.                                                                                                                                                                                                   |

#### Example

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<coupons
    version="2.17"
    totalItems="1"
>
    <c id="DiscountChristmas2024">
        <reusable>0</reusable>
        <discountType>PERCENTUAL</discountType>
        <discount>10.20</discount>
        <validFrom>2020-04-10T00:00:00</validFrom>
        <validTo>2020-04-17T00:00:00</validTo>
        <values>
			<v>D4dg47</v>
			<v>B45s48</v>
            <v contactId="646GS">ABSCDF</v>
            <v>GHCJKD</v>
            <v>D45s45</v>
			...
        </values>
    </c>
</coupons>
```

#### Creating New Coupons

Unlike other feeds, the coupon feed also allows for creating new items.
If you want Incomaker to send coupons within an email campaign, it can use this method to create coupons on the fly.

In order to create new coupons, there is an additional parameter **downloadCount** that causes the immediate generation of requested number of coupons and their download in the feed (if the e-commerce platform supports such behavior).

Parameter **id** denotes type (or *template*) for newly created coupons.

Following example will generate 1000 new coupons of type **DiscountChristmas2024**:

    https://www.myeshop.com/feed.php?key=86342b04-fa97-4fde-baa5-c3f912b88430&type=coupon&id=DiscountChristmas2024&downloadCount=1000


### Info

This special xml feed contains a single collection of fields where you can provide us with additional information about your e-shop.

| Custom Field Name  | Description |
|--------------------|-------------|
| **ico**            | ?           |
| **dic**            | ?           |
| **date_subscribe** | ?           |

#### Example

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<info version="2.15">
    <contact>
        <customFields>
            <c id="ico">IČO</c>
            <c id="dic">DIČ</c>
            <c id="date_subscribe">Datum přihlášení</c>
            <c id="date_unsubscribe">Datum odhlášení</c>
            <c id="price_level_id">ID cenové hladiny</c>
            <c id="price_level">Cenová hladina</c>
            <c id="users_groups_1">Skupina uživatelů: Odběr novinek</c>
            <c id="users_groups_8">Skupina uživatelů: Dotaz na produkt</c>
            <c id="users_groups_686">Skupina uživatelů: Hlídací pes</c>
            <c id="users_groups_96841">Skupina uživatelů: VIVA</c>
            <c id="custom_data_profilePicture">profilePicture</c>
            <c id="custom_data_birthdate">birthdate</c>
            <c id="custom_data_found_us_where">found_us_where</c>
        </customFields>
    </contact>
</info>
```

## XML Feed Validation

It is a time-saver for both you and us if you verify your feeds before submitting them to Incomaker.

There are XML Schema Definition files inside `xsd` folder of this repository
that will help you validate your feeds.

### Online

One possibility is to use free online [XML validator](https://www.freeformatter.com/xml-validator-xsd.html) - just upload your feed and corresponding XSD file.

### Linux

Another option is to validate feeds with a `xmllint` program for Linux:

Install:

    sudo apt-get install libxml2-utils

Validate a feed:

    xmllint --schema xsd/orders.xsd orders.xml --noout

Export XML file formatted the for human readability:

    xmllint orders.xml --format --output orders.formatted.xml

#### Docker

You can use enclosed Docker container and scripts to validate XML feed:

    ./validate-docker orders my-orders-feed.xml

on Windows:

    validate-docker.cmd orders %cd%/my-orders-feed.xml
