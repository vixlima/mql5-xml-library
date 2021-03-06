//+------------------------------------------------------------------+
//|                                                    CUnitTestss.mq5 |
//|                                     Copyright 2015, Louis Fradin |
//|                                      http://en.louis-fradin.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Louis Fradin"
#property link      "http://en.louis-fradin.net/"
#property version   "1.00"
#include "../modules/unit-test-library/UnitTest-Library.mqh"
#include "../src/XML.mqh"
//+------------------------------------------------------------------+
//| Class to access private functions for tests
//+------------------------------------------------------------------+
class PrivateAccessXML : public CXML{
   public:
      int AccessParseNode(CXMLNode *node, string text, int position = 0){
         return ParseNode(node, text, position);
      }    
      int AccessParseAttribute(CXMLNode *node, string text, int position){
         return ParseAttribute(node, text, position);
      }
      int AccessParseContent(CXMLNode* node, string text, int position){
         return ParseContent(node, text, position);
      }
};
//+------------------------------------------------------------------+
//| Summary of tests
//+------------------------------------------------------------------+
void OnStart(){
   CUnitTestsCollection utCollection();
   utCollection.AddUnitTests(ParseAttribute_Test());
   utCollection.AddUnitTests(ParseContent_Test());
   utCollection.AddUnitTests(ParseNode_Test());
   utCollection.AddUnitTests(Informations_Test());
   utCollection.AddUnitTests(ExportImport_Test());
}
//+------------------------------------------------------------------+
//| Test of ParseAttribute method
//+------------------------------------------------------------------+
CUnitTests* ParseAttribute_Test(){
   CUnitTests* ut = new CUnitTests("Parse Attribute Test");
   PrivateAccessXML xml();
   CXMLAttribute *attribute, *attributeSon;
   CXMLNode *node = new CXMLNode();
   string text;
   // TEST1 : 4 attributes without error
   text = "attribute1='text1' attribute2=\"text2\" attribute3=text3 attribute4";
   xml.AccessParseAttribute(node, text, 0);
   // Attribute 1
   attribute = node.GetFirstAttribute();
   if(ut.IsTrue(__FILE__, __LINE__, attribute!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute1", attribute.GetName());
      ut.IsEquals(__FILE__, __LINE__, "text1", attribute.GetText());
   }
   // Attribute2
   attributeSon = attribute.GetChildren();
   if(ut.IsTrue(__FILE__, __LINE__, attributeSon!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute2", attributeSon.GetName());
      ut.IsEquals(__FILE__, __LINE__, "text2", attributeSon.GetText());
   }
   // Attribute3
   attributeSon = attributeSon.GetChildren();
   if(ut.IsTrue(__FILE__, __LINE__, attributeSon!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute3", attributeSon.GetName());
      ut.IsEquals(__FILE__, __LINE__, "text3", attributeSon.GetText());
   }
   // Attribute4
   attributeSon = attributeSon.GetChildren();
   if(ut.IsTrue(__FILE__, __LINE__, attributeSon!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute4", attributeSon.GetName());
      ut.IsEquals(__FILE__, __LINE__, "", attributeSon.GetText());
   }
   // TEST2 : 2 attributes with a lot of spaces
   text = "     attribute1    =     'text1'   attribute2   =   text2";
   node.DeleteAll();
   xml.AccessParseAttribute(node, text, 0);
   // Attribute 1
   attribute =  node.GetFirstAttribute();
   if(ut.IsTrue(__FILE__, __LINE__, attribute!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute1", attribute.GetName());
      ut.IsEquals(__FILE__, __LINE__, "text1", attribute.GetText());
   }
   // Attribute2
   attributeSon = attribute.GetChildren();
   if(ut.IsTrue(__FILE__, __LINE__, attributeSon!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute2", attributeSon.GetName());
      ut.IsEquals(__FILE__, __LINE__, "text2", attributeSon.GetText());
   }
   // TEST3: End of the arguments
   text = "attribute1='text1'> attribute2=text2";
   node.DeleteAll();
   xml.AccessParseAttribute(node, text, 0);
   // Attribute 1
   attribute = node.GetFirstAttribute();
   if(ut.IsTrue(__FILE__, __LINE__, attribute!=NULL)){
      ut.IsEquals(__FILE__, __LINE__, "attribute1", attribute.GetName());
      ut.IsEquals(__FILE__, __LINE__, "text1", attribute.GetText());
   }
   // Attribute2
   attributeSon = attribute.GetChildren();
   ut.IsTrue(__FILE__, __LINE__, attributeSon==NULL);
   delete node;
   return ut;
}
//+------------------------------------------------------------------+
//| Test of ParseContent method
//+------------------------------------------------------------------+
CUnitTests* ParseContent_Test(){
   CUnitTests* ut = new CUnitTests("Parse Content Test");
   CXMLNode *node, *nodeSon;
   PrivateAccessXML xml();
   string text;
   node = new CXMLNode();
   node.SetName("node"); // Set the name
   // TEST1 : With only text
   text = "     Bonjour � tous   </node>";
   xml.AccessParseContent(node, text, 0);
   ut.IsEquals(__FILE__, __LINE__, "Bonjour � tous", node.GetText());
   // TEST2 : With another node as a child
   text = "     <child>TEXT</child> </node>";
   node.DeleteAll();
   xml.AccessParseContent(node, text, 0);
   ut.IsEquals(__FILE__, __LINE__, "", node.GetText());
   if(ut.IsTrue(__FILE__, __LINE__, node.GetChild()!=NULL)){
      nodeSon = node.GetChild();
      ut.IsEquals(__FILE__, __LINE__, "child", nodeSon.GetName());
      ut.IsEquals(__FILE__, __LINE__, "TEXT", nodeSon.GetText());
   }
   delete node;
   return ut;
}
//+------------------------------------------------------------------+
//| Test of ParseNode method
//+------------------------------------------------------------------+
CUnitTests* ParseNode_Test(){
   CUnitTests* ut = new CUnitTests("Parse Node Test");
   PrivateAccessXML xml();
   string text;
   CXMLNode *node, *child;
   CXMLAttribute *attribute;
   node = new CXMLNode();
   // TEST1 : With only text
   text = "<node>     Bonjour � tous   </node>";
   xml.AccessParseNode(node, text, 0);
   ut.IsEquals(__FILE__, __LINE__, "node", node.GetName());
   ut.IsEquals(__FILE__, __LINE__, "Bonjour � tous", node.GetText());
   // TEST2 : With 2 children
   node.DeleteAll();
   text = "<node>   <child1>Bonjour � tous</child1> <child2/>  </node>";
   xml.AccessParseNode(node, text, 0);
   // On node
   ut.IsEquals(__FILE__, __LINE__, "node", node.GetName());
   ut.IsEquals(__FILE__, __LINE__, "", node.GetText());
   // On child
   child = node.GetChild();
   ut.IsEquals(__FILE__, __LINE__, "child1", child.GetName());
   ut.IsEquals(__FILE__, __LINE__, "Bonjour � tous", child.GetText());
   // On child's brother
   child = child.GetBrother();
   ut.IsEquals(__FILE__, __LINE__, "child2", child.GetName());
   ut.IsEquals(__FILE__, __LINE__, "", child.GetText());
   // TEST3 : With 2 argumented children
   node.DeleteAll();
   text = "<node>   <child1 argument1='text1'>Bonjour � tous</child1> <child2 argument1='text1' argument2='text2' />  </node>";
   xml.AccessParseNode(node, text, 0);
   // On child
   child = node.GetChild();
   attribute = child.GetFirstAttribute();
   ut.IsEquals(__FILE__, __LINE__, "argument1", attribute.GetName());
   ut.IsEquals(__FILE__, __LINE__, "text1", attribute.GetText());
   // On child's brother
   child = child.GetBrother();
   attribute = child.GetFirstAttribute();
   ut.IsEquals(__FILE__, __LINE__, "child2", child.GetName());
   ut.IsEquals(__FILE__, __LINE__, "argument1", attribute.GetName());
   ut.IsEquals(__FILE__, __LINE__, "text1", attribute.GetText());
   attribute = attribute.GetChildren();
   ut.IsEquals(__FILE__, __LINE__, "argument2", attribute.GetName());
   ut.IsEquals(__FILE__, __LINE__, "text2", attribute.GetText());
   // TEST4 : With a child and a grand-child
   node.DeleteAll();
   text = "<node>   <child1>Bonjour � tous<child2/></child1>  </node>";
   xml.AccessParseNode(node, text, 0);
   // On node
   ut.IsEquals(__FILE__, __LINE__, "node", node.GetName());
   ut.IsEquals(__FILE__, __LINE__, "", node.GetText());
   // On child
   child = node.GetChild();
   ut.IsEquals(__FILE__, __LINE__, "child1", child.GetName());
   ut.IsEquals(__FILE__, __LINE__, "Bonjour � tous", child.GetText());
   // On grand child
   child = child.GetChild();
   ut.IsEquals(__FILE__, __LINE__, "child2", child.GetName());
   ut.IsEquals(__FILE__, __LINE__, "", child.GetText());
   delete node;
   return ut;
}
//+------------------------------------------------------------------+
//| Test of informations
//+------------------------------------------------------------------+
CUnitTests* Informations_Test(){
   CUnitTests* ut = new CUnitTests("Informations Test");
   // Test information concerning number of children
   CXMLNode* parentNode = new CXMLNode();
   CXMLNode* child1 = new CXMLNode();
   CXMLNode* child2 = new CXMLNode();
   ut.IsEquals(__FILE__,__LINE__,0,parentNode.GetChildrenNbr());
   parentNode.AddChild(child1);
   parentNode.AddChild(child2);
   ut.IsEquals(__FILE__,__LINE__,2,parentNode.GetChildrenNbr());
   delete parentNode;
   // Test information concerning number of brothers
   CXMLNode* node = new CXMLNode();
   CXMLNode* brother1 = new CXMLNode();
   CXMLNode* brother2 = new CXMLNode();
   ut.IsEquals(__FILE__,__LINE__,0,node.GetBrothersNbr());
   node.AddBrother(brother1);
   node.AddBrother(brother2);
   ut.IsEquals(__FILE__,__LINE__,2,node.GetBrothersNbr());
   delete node;
   return ut;
}
//+------------------------------------------------------------------+
//| Test of export/import
//+------------------------------------------------------------------+
CUnitTests* ExportImport_Test(){
   CUnitTests* ut = new CUnitTests("Export/Import Test");
   // Creation of the tree
   CXMLNode *root = new CXMLNode("root");
   CXMLNode *child1 = new CXMLNode("child1");
   root.AddChild(child1);
   CXMLNode *grandChild = new CXMLNode("GrandChild");
   child1.AddChild(grandChild);
   CXMLNode *child2 = new CXMLNode("child2");
   root.AddChild(child2);
   CXMLNode *child3 = new CXMLNode("child3");
   root.AddChild(child3);
   // Export
   CXML file();
   file.SetDocumentRoot(root);
   ut.IsTrue(__FILE__, __LINE__, file.Save("XML_test"));
   // Cleaning
   file.Clear();
   // Import
   ut.IsTrue(__FILE__, __LINE__, file.ReadFromFile("XML_test"));
   root = file.GetDocumentRoot();
   if(ut.IsEquals(__FILE__,__LINE__,3, root.GetChildrenNbr())){
      child1 = root.GetChild();
      ut.IsEquals(__FILE__,__LINE__,"child1", child1.GetName());
      child2 = child1.GetBrother();
      ut.IsEquals(__FILE__,__LINE__,"child2", child2.GetName());
      child3 = child2.GetBrother();
      ut.IsEquals(__FILE__,__LINE__,"child3", child3.GetName());
   }
   delete root;
   return ut;
}
//+------------------------------------------------------------------+
