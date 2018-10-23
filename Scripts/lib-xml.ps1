############################################################################## 
# Get an XPath Navigator object based on the input string containing xml
function get-xpn ($text) { 
    $rdr = [System.IO.StringReader] $text
    $trdr = [system.io.textreader]$rdr
    $xpdoc = [System.XML.XPath.XPathDocument] $trdr
    $xpdoc.CreateNavigator()
}