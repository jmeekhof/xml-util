xquery version '1.0-ml';

module namespace xutil = "http://twotheleft.com/xml-util";

declare option xdmp:mapping "false";

(:~
 : This functions takes a sequence of strings, or a map and returns a map made
 : by alternating the values as key value pairs
 :
 : @author Josh Meekhof
 : @version 1
 : @param $ns a sequence of xs:strings or a map:map
 : @return map:map
 :)
declare function xutil:parse-alternating-sequence( $ns as item()+) as map:map
{
  if ( $ns[1] instance of xs:string ) then
    let $count := fn:count($ns) idiv 2 (:how many alternating groups do I have:)
    let $entry :=
      (1 to $count) !
      map:entry( fn:subsequence($ns, (.) * 2 -1, 1), fn:subsequence($ns, (.) * 2, 1 ) )

    return map:new($entry)
  else if ( $ns instance of map:map ) then
    $ns
  else
    fn:error()
};

(:~
 : returns a namespace suitable for insertion in an element contructor
 : @author Josh Meekhof
 : @version 1
 : @param $ns-map a sequence of xs:string or map:map
 : @return namespace
 :)
declare function xutil:namespace-axis(
  $ns-map as item()+) as item()*
{
  let $ns := xutil:parse-alternating-sequence($ns-map)
  let $e := "<e " ||
    string-join(
      for $prefix in map:keys($ns)
      return
        if ( $prefix = "" ) then
          'xmlns="' || map:get($ns, $prefix) || '"'
        else
          'xmlns:' || $prefix || '="' || map:get($ns, $prefix) || '"'
    ," ")
    || '/>'

  return xdmp:unquote($e)/*/namespace::*
};


(:~
 : returns a node with the namespace prefixes normalized throughout
 : @author Josh Meekhof
 : @version 1
 : @param $node the document or node to be operated upon
 : @param $ns alternating sequence of prefix, namespace or a map:map
 : @return The nodes with normalized namespaces
 :)
declare function xutil:clean-ns-deep(
  $node as node(),
  $ns as item()+) as node()*
{

let $node :=
  if ($node instance of document-node() ) then
    $node/*
  else
    $node
let $ns := xutil:parse-alternating-sequence($ns)
return
  element { fn:node-name($node) }
    {
    xutil:namespace-axis($ns),
    xutil:ns-clean-deep-recurse($node/node(),$ns)
    }
};

declare function xutil:ns-clean-deep-recurse(
  $nodes as node()*,
  $ns-map as map:map) as node()*
{
  let $reverse-map := -$ns-map
  for $node in $nodes
    return
      if ($node instance of element() ) then
        let $ns := fn:namespace-uri($node)

        return
        if ( map:contains($reverse-map, $ns) ) then
        (
          let $prefix := map:get($reverse-map, $ns)
          return
          element {
            fn:QName (
              $ns,
              concat(
                $prefix,
                  if ( $prefix = '') then
                    ''
                  else
                    ':',
                fn:local-name($node) ) ) } { $node/@*,
                xutil:ns-clean-deep-recurse($node/node(), $ns-map) }
        )

        else
        (
          $node,
          xutil:ns-clean-deep-recurse($node/node(), $ns-map)
        )
      else
        $node
};

(:~
 : Recursively walks through a node and removes the empty elements
 : @param $node the node you want to have the empty elements removed
 : @return the element with all the empty nodes removed
 :)
declare function xutil:remove-empty-elements($node as node()) as element()? {
  let $element :=
    if ($node instance of document-node() ) then
      $node/*
    else
      $node
  return
    if ( $element/* or $element/text() ) then
      element { fn:node-name($element) } {
        $element/@*, $element/node() !
        (
          if ( . instance of element() ) then
            xutil:remove-empty-elements(.)
          else
            .
        )
      }
    else
      ()
};
