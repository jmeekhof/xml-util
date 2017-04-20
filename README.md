# XML-UTIL
XQuery Utility Functions

When constructing xml documents using element constructor, namespaces and prefixes can get a bit messy.
The reason for this is because element constructors don't allow you to modify namespaces and their prefixes.
Using `xutil:clean-ns-deep` will make your entire document consistent by recursively applying your specified prefixes across the document.

#Usage

The `clean-ns-deep` function accepts your document or document fragment and your desired namespaces and prefixes.
The namespaces and prefixes may be specified by either a sequence of alternating strings or a map:map.

```xquery
xquery version '1.0-ml';
import module namespace xutil = "http://twotheleft.com/xml-util" from "/xml-util/xml-util.xqy";
let $messy-doc :=
  <example xmlns="http://twotheleft.com/example">
    <c:foo xmlns:c="http://twotheleft.com/example">Example</c:foo>
  </example>

return xutil:clean-ns-deep($messy-doc, ("","http:twotheleft.com/example"))
```

This will remove the extraneous `xmlns:c="http://twotheleft.com/example"` from our xml.


