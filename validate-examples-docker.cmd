rem Verifies that all example xml files are compliant with XSD schema definition

call validate-docker.cmd categories %cd%/examples/categories.xml
call validate-docker.cmd products %cd%/examples/products.xml
call validate-docker.cmd contacts %cd%/examples/contacts.xml
call validate-docker.cmd orders %cd%/examples/orders.xml
call validate-docker.cmd couponTemplates %cd%/examples/couponTemplates.xml
call validate-docker.cmd coupons %cd%/examples/coupons.xml
call validate-docker.cmd info %cd%/examples/info.xml
