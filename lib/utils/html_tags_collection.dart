
import 'dart:collection';

class HtmlTagsCollection  {
  List<String> sameLineStartTagsList = [
    '<h1>',
    '<h2>',
    '<h3>',
    '<h4>',
    '<h5>',
    '<h6>',
    '<p>',
    '<li>',
    '<ol>',
    '<ul>',
    '<strong>',
    '<b>',
    '<i>',
    '<a href=\"',
    '\" target=\"_blank\">'
  ],
      sameLineEndTagsList = [
        '</ol>',
        '</ul>',
        '</strong>',
        '</b>',
        '</i>',
        '</a>',
      ],
      newLineEndTagsList = [
        '</h1>',
        '</h2>',
        '</h3>',
        '</h4>',
        '</h5>',
        '</h6>',
        '</li>',
        '</p>',
        '<br />',
        '<br />',
        '<br>',
      ];
  LinkedHashMap<String, List<String>> tagsLinkedHashMap=LinkedHashMap<String, List<String>>();
}