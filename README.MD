# Incomaker XML Feed Standards

This repository contains documentation for implementation of Incomaker XML feeds, 
XSD files for feed validation and an output XML examples..

## Submitting the Base URL

Instead of painstaking integration of full API and passing all data through the calls, 
just provide Incomaker with the following data.
Incomaker will download data from the shop repeatedly, approximately once per day.

You should create the following data feeds:

- Categories
- Products
- Contacts
- Orders
- Coupons

### Feed Base URL

All feeds should be available at the **Base URL** specified at the plugin registration.
The expected URL with parameters that will be called from Incomaker could look like the following:

    https://www.myeshop.com/feed.php?key=86342b04-fa97-4fde-baa5-c3f912b88430&type=product

Everything before `?` sign is a **Base URL** (in this example: `https://www.myeshop.com/feed.php`), 
everything after it are parameters that will be added by Incomaker when downloading your feed.

You will have to provide Incomaker with your **Base URL**.

Please, see the full list of parameters to implement below.

### Feed Parameters

| Param Name        | Required     | Type    | Description                                                                                                                                                                                                                                                                                                                                                                                               |
|-------------------|--------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **key**           | **required** | UUID    | Api Key returned from the register plugin function                                                                                                                                                                                                                                                                                                                                                        |
| **type**          | **required** | string  | Indicates type of returned feed: (**category**, **product**, **contact**, **order** or **coupon**)                                                                                                                                                                                                                                                                                                        |
| **id**            | optional     | string  | An internal identifier of an item to be returned. If the request with this parameters is called, Incomaker expects to receive one item (i.e. one product) with the respective ID. The ID is the internal ID of the eshop. Id has the highest priority. If it is used in the call together with since, limit, or offset, ID is the only parameter to follow                                                |
| **since**         | optional     | date    | When the request is called with since-parameter, it is expected to return just the changes made since the respective date (inclusive). If it is technically impossible to implement it, you can always return the full list of items, and Incomaker distinguish the changes automatically. However, it is **strongly recommended** to implement it in order to save traffic and server load on both sides |
| **limit**         | optional     | integer | Maximum number of items that should be returned in the call. Incomaker always tries to request the items in batches of reasonable sizes, however it is recommended to limit the maximum number of returned items for the security reasons. Optionally could be used together with **offset**                                                                                                              |
| **offset**        | optional     | integer | First item that will be returned in the requested batch. Can be used together with **limit** only                                                                                                                                                                                                                                                                                                         |
| **downloadCount** | optional     | integer | Only relevant for **type=coupon**. Indicates the number of coupons to be generated                                                                                                                                                                                                                                                                                                                        |

## Feed Data Structure

Incomaker expects the feeds provided by the e-shop in the following formats. Most of the fields are optional, however you should provide as much as possible. The intelligence of Incomaker is dependent on data available, and the more data we have the better results we deliver.

From version 2.6 on, the root element contains a mandatory attribute version with the protocol version. Omitting this attribute means version < 2.6.

In all cases, the root element (products, orders, etc.) can contain an optional attribute **totalItems** containing the total number of items of the current entity. It means all the available entities no matter of pagination, limits, offset, etc. of the particular feed request.

For each feed, a link to XSD schema file is enclosed.

### Date formats

All dates should be formatted in ISO date format.

**date** - **YYYY-MM-DD** (example: 2023-06-24)

**datetime** - **YYYY-MM-DDTHH:mm:ss** (example: 2023-06-24T13:00:24)

Optionally, **datetime** can also include time zone (example: 2023-06-24T13:00:24+02:00), timezone you entered during plugin registration will be used otherwise

### CustomFields

A map of custom fields where any related value can be stored.
Used for adding extra information not covered by standard fields.

#### CustomField

Root element tag: **f**

| Attribute Name | Required     | Type   | Description                        |
|----------------|--------------|--------|------------------------------------|
| **key**        | **required** | string | Name of custom field               |
| **group**      | optional     | string | Logical grouping of related fields |

#### Example

```xml
<customFields>
    <f key="ShoeSize" group="trait">L</f>
    <f key="EyeColor" group="trait">blue</f>
</customFields>
```

### Tags

A set of simple tags.

#### Example 

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

| Attribute Name | Required     | Type   | Description                                                                                   |
|----------------|--------------|--------|-----------------------------------------------------------------------------------------------|
| **id**         | **required** | string | An internal category identifier. This Id must match with the Id used in Products and Orders.  |


| Element Name         | Required     | Type         | Description                                             |
|----------------------|--------------|--------------|---------------------------------------------------------|
| **parentCategoryId** | optional     | string       | An internal category identifier of the parent category. |
| **languages**        | **required** | string       | An internal category identifier of the parent category. |
| **url**              | optional     | string       | The URL of the category.                                |
| **customFields**     | optional     | CustomFields |                                                         |

#### CategoryLanguages

Caption and links for the individual languages.

Root element tag: **languages**

##### CategoryLanguage

Root element tag: **l**

| Attribute Name | Required     | Type   | Description                                                                                                                                                   |
|----------------|--------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **id**         | **required** | string | ISO code of the language is preferred (e.g. **en**). IETF language tag (e.g. **en-US**) could be also used, but anything from the third character is ignored. |


| Element Name | Required     | Type         | Description                             |
|--------------|--------------|--------------|-----------------------------------------|
| **name**     | **required** | string       | Name of the category in given language. |
| **url**      | optional     | string       | URL of category page in given language. |

#### Example

```xml
<?xml version="1.0"?>
<categories version="2.14" totalItems="2">
    <c id="1">
        <languages>
            <l id="en">
                <name>Rockets</name>
            </l>
        </languages>
    </c>
    <c id="2">
        <parentCategoryId>2</parentCategoryId>
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

#### Example

```xml

```

### Contacts

Collection of e-shop customers.

Root element tag: **contacts**

#### Contact

Root element tag: **c**

| Attribute Name | Required     | Type   | Description                         |
|----------------|--------------|--------|-------------------------------------|
| **id**         | **required** | string | An Id of the contact in the e-shop  |

| Element Name     | Required | Type         | Description                                           |
|------------------|----------|--------------|-------------------------------------------------------|
| **firstName**    | optional | string       |                                                       |
| **lastName**     | optional | string       |                                                       |
| **sex**          | optional | string       | Possible values: **MALE**, **FEMALE** or **UNKNOWN**  |
| **email**        | optional | string       |                                                       |
| **language**     | optional | string       | The language code (ISO 639-1, e.g. en)                |
| **birthday**     | optional | date         |                                                       |
| **consentDate**  | optional | datetime     | GDPR consent date                                     |
| **consentTitle** | optional | string       | GDPR consent title                                    |
| **web**          | optional | string       |                                                       |
| **remarks**      | optional | string       |                                                       |
| **street**       | optional | string       |                                                       |
| **street2**      | optional | string       |                                                       |
| **city**         | optional | string       |                                                       |
| **zipCode**      | optional | string       |                                                       |
| **phoneNumber1** | optional | string       |                                                       |
| **phoneNumber2** | optional | string       |                                                       |
| **country**      | optional | string       | ISO country code (two letters)                        |
| **newsletter**   | optional | byte         | Is customer subscribed to a newsletter? (0=no, 1=yes) |
| **currency**     | optional | string       | Customer’s default currency                           |
| **pricelist**    | optional | string       | Customer’s default pricelist                          |
| **tags**         | optional | Tags         |                                                       |
| **customFields** | optional | CustomFields |                                                       |

#### Example

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<contacts version="2.14.0" totalItems="6040">
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

### Coupons

#### Download Count

Unlike other feeds, the coupon feed has a special optional parameter **downloadCount** that causes the immediate generation of the requested number of coupons and their download in the feed (if the e-commerce platform supports such behavior).
Enter the number of needed coupons.

Example:

    https://www.myeshop.com/feed.php?key=86342b04-fa97-4fde-baa5-c3f912b88430&type=coupon&id=Discount&downloadCount=1000

#### CouponValues

The list of actual coupon codes.

##### Example

```xml
<values>
    <v>ABSCDF</v>
    <v>GHCJKD</v>
    <v>D45s45</v>
</values>
```

#### Coupon

Root element tag: **c**

| Attribute Name | Required     | Type   | Description                             |
|----------------|--------------|--------|-----------------------------------------|
| **id**         | **required** | string | An Id of the coupon type in the e-shop. |

| Element Name     | Required     | Type         | Description                                                                                                                                                                                                                    |
|------------------|--------------|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **reusable**     | **required** | byte         | Whether this type of coupon can be used multiple times. **0**=no, **1**=yes. Reusable coupons are typically used as a single code for multiple users. Non-reusable coupon is usually personalized, and we can track its usage. |
| **discountType** | optional     | string       | Possible values: **PERCENTUAL**, **MONETARY**                                                                                                                                                                                  |
| **discount**     | optional     | string       | Either the monetary or percentual value of the coupon type.                                                                                                                                                                    |
| **validFrom**    | optional     | datetime     |                                                                                                                                                                                                                                |
| **validTo**      | optional     | datetime     |                                                                                                                                                                                                                                |
| **values**       | **required** | CouponValues | The list of actual coupon codes.                                                                                                                                                                                               |
| **customFields** | optional     | CustomFields |                                                                                                                                                                                                                                |

#### Example

```xml
<coupons version="2.13">
    <c id="DISCOUNT_10">
        <reusable>0</reusable>
        <discountType>PERCENTUAL</discountType>
        <discount>10.20</discount>
        <validFrom>2020-04-10T00:00:00</validFrom>
        <validTo>2020-04-17T00:00:00</validTo>
        <values>
            <v>ABSCDF</v>
            <v>GHCJKD</v>
            <v>D45s45</v>
        </values>
        <customFields>
            <f key="MaximumUseByPerson" group="parameters">2</f>
            <f key="MaximumTotalUse" group="parameters">1000</f>
            <f key="ImageUrl">https://www.eshop.cz/coupons/12234.jpg</f>
        </customFields>
    </c>
</coupons>
```

## XML Feed Validation

It is a time-saver for both you and us if you verify your feeds before submitting them to Incomaker.

There are XML Schema Definition files inside `xsd` folder of this repository 
that will help you validate your feeds.

### Online

One possibility is to use free online 
[XML validator](https://www.freeformatter.com/xml-validator-xsd.html) - just upload
your feed and corresponding XSD file. 

### Linux

Another option is to validate feeds with a `xmllint` program for Linux:

Install:

    sudo apt-get install libxml2-utils

Validate a feed:

    xmllint --schema xsd/orders.xsd orders.xml --noout

Format the XML feed for human readability:

    xmllint orders.xml --format --output orders.formatted.xml
