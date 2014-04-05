class TreeController < ApplicationController
  def walk_category_recursive(level, parent)
    ret = ""
    parent.children.each do |node|
      ret += "#{level}, \'"
      ret += yield level, node
      ret += "\',\n"
      ret += walk_category_recursive(level + 1, node) { |lvl, n| yield lvl, n } unless node.children.empty?
    end
    ret
  end

  def category_tree_data_builder(tree_data)
    data = "var #{tree_data} = [" +
      walk_category_recursive(0, Category.root) {|lvl, node| link_to(h(truncate(node.title, (30 - lvl))), {:controller => 'topic', :action => 'show', :id => node}) }
    # chop off the last trailing comma
    data.chomp!.chop!
    return data + "];\n"
  end

  # TODO no response
  def yui_tree_builder(tree_div_id, tree_data, expanded_label = "NONE" )
    return "var tree; \n" +
      "function #{tree_div_id}Init() {\n"+
      "tree = new YAHOO.widget.TreeView(\"#{tree_div_id}\");\n"+
      "addChildrenNodes(0, 0, tree.getRoot());\n"+
      "tree.draw();\n"+
      "};\n"+
      "function addChildrenNodes(currLevel, nodeIndex, parent) { \n" +
      "var lastNode;\n"+
      "var level = currLevel;\n"+
      "while (nodeIndex < #{tree_data}.length) {\n"+
      "var level = #{tree_data}[nodeIndex];\n"+
      "if (level == currLevel) {\n"+
      "nodeIndex++;\n"+
      "if (#{tree_data}[nodeIndex].indexOf(\"/#{expanded_label}-\") < 0) {\n" + 
      "lastNode = new YAHOO.widget.HTMLNode({html: \"<div class='browserNaviNotSelected'>\" + #{tree_data}[nodeIndex] + \"</div>\"}, parent, false, true);\n"+
      "lastNode.multiExpand = false;\n"+                    
      "lastNode.nowrap = true;\n"+
      "} else {\n" +
      "lastNode = new YAHOO.widget.HTMLNode({html: \"<div id='browserNaviCenter'><div id='browserNaviItem'>\" +  #{tree_data}[nodeIndex] + \"</div></div>\"}, parent, true, true);\n"+
      "lastNode.multiExpand = false;\n"+
      "lastNode.nowrap = true;\n"+
      "var p = parent;\n"+
      "while (p != null) {\n"+
      "p.expanded = true;\n"+
      "p = p.parent;\n"+
      "}\n"+
      "}\n"+
      "nodeIndex++;\n"+
      "} else if (level < currLevel) {\n"+
      "return nodeIndex;\n"+
      "} else {\n"+
      "nodeIndex = addChildrenNodes(level, nodeIndex, lastNode);\n"+
      "}\n"+
      "}\n"+
      "return nodeIndex;\n"+
      "};\n"+
      "YAHOO.util.Event.onDOMReady(#{tree_div_id}Init);\n"
  end

  def index 
    yui_tree_builder('mytree', tree_data, nil)
  end
end
