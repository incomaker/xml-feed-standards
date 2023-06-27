# Incomaker XML Feed Standards

This repository contains documentation for implementation of Incomaker XML feeds, XSD files for feed validation and output XML examples..

## XML Feed Validation
 
One possibility is to use free online [XML validator](https://www.freeformatter.com/xml-validator-xsd.html) - just upload your feed and corresponding XSD file. 

Another option is to validate feed with a `xmllint` program for Linux:

Install:

    sudo apt-get install libxml2-utils

Validate feed:

    xmllint --schema xsd/orders.xsd orders.xml --noout
