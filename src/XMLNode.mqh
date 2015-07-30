//+------------------------------------------------------------------+
//|                                                      XMLNode.mqh |
//|                                     Copyright 2014, Louis Fradin |
//|                                      http://en.louis-fradin.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Louis Fradin"
#property link      "http://en.louis-fradin.net/"
// Includes
#include "XMLAttribute.mqh"
//+------------------------------------------------------------------+
//| Prototype                                                        |
//+------------------------------------------------------------------+
class CXMLNode{
   private:
      string m_name;
      string m_text;
      string m_comment;
      CXMLAttribute *m_attributes;
      CXMLNode *m_brothers;
      CXMLNode *m_children;
      void WithForbiddenLetters(string& entryString);
      void WithoutForbiddenLetters(string& entryString);
   public:
      CXMLNode();
      CXMLNode(string name);
      ~CXMLNode();
      void DeleteAll(); // Deletes attributes, children and little brothers
      string GenerateText(int depth = 0, bool brothers = true); // Generate a XML text formated version of the node, his children and, if yes, little brothers
      void ReadAll(int depth = 0);
      // Operations on attributes
      void AddAttribute(string name, string text);
      void AddAttribute(CXMLAttribute *attribute);
      void DeleteAttributes(); // Delete all attributes of the node
      CXMLAttribute* GetAttribute(string name);
      // Operations on children
      void AddChild(CXMLNode* child); // Add a child to the node
      CXMLNode* DetachChildren(); // Detach all chidren (Be careful: you have to handle the children or you will loose memory)
      void DeleteChild(); // Delete the first child of the node, preserving brothers and little children
      void DeleteChildren(); // Delete All children of the node
      CXMLNode* GetChild(string name); // Get a children by its name
      // Operations on brothers
      void AddBrother(CXMLNode* brother); // Add a brother to the node
      CXMLNode* DetachBrothers(); // Detach all little brothers from this node
      void DeleteBrothers(); // Delete all little brothers of this node
      // Informations
      int GetBrothersNbr(); // Return the number of brothers
      int GetChildrenNbr(); // Return the number of brothers
      // Accessors
      string GetName();
      string GetText();
      string GetComment();
      CXMLAttribute* GetAttribute();
      CXMLNode* GetChild();
      CXMLNode* GetBrother();
      // Mutators
      void SetName(string name);
      void SetText(string text);
      void SetComment(string comment);
};
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CXMLNode::CXMLNode(){
   m_name = "unknown";
   m_text = "";
   m_comment = "";
   m_attributes = NULL;
   m_brothers = NULL;
   m_children = NULL;
}
//+------------------------------------------------------------------+
//| Constructor
//| @param name Name of the node
//+------------------------------------------------------------------+
CXMLNode::CXMLNode(string name){
   StringReplace(name, " ", "_"); // Replacement of spaces
   this.WithoutForbiddenLetters(name);
   m_name = name;
   m_text = "";
   m_comment = "";
   m_attributes = NULL;
   m_brothers = NULL;
   m_children = NULL;
}
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CXMLNode::~CXMLNode(){
   this.DeleteAll();
}
//+------------------------------------------------------------------+
//| Replace Forbidden Characters
//| @param entryString String to analyse
//| @return The string with forbidden letters
//+------------------------------------------------------------------+
void CXMLNode::WithForbiddenLetters(string& entryString){
   StringReplace(entryString, "&#60", "<"); // Replacement of <
   StringReplace(entryString, "&#61", "="); // Replacement of =
   StringReplace(entryString, "&#62", ">"); // Replacement of >
}
//+------------------------------------------------------------------+
//| Replace Forbidden Characters
//| @param entryString String to analyse
//| @return The string without forbidden letters
//+------------------------------------------------------------------+
void CXMLNode::WithoutForbiddenLetters(string& entryString){
   StringReplace(entryString, "<", "&#60"); // Replacement of <
   StringReplace(entryString, "=", "&#61"); // Replacement of =
   StringReplace(entryString, ">", "&#62"); // Replacement of >
}
//+------------------------------------------------------------------+
//| Clear the node from its attributes, children and brothers
//+------------------------------------------------------------------+
void CXMLNode::DeleteAll(){
   this.DeleteAttributes();
   this.DeleteChildren();   
   this.DeleteBrothers();
}
//+------------------------------------------------------------------+
//| Generate XML text
//| @param depth The depth of the node in the DOM
//| @param brothers Do it generate brothers ?
//| @return The generated text
//+------------------------------------------------------------------+
string CXMLNode::GenerateText(int depth = 0, bool brothers = true){
   string text = "";
   string shift = "";
   // creating the shift
   for(int i = 0; i < depth; i++)
      shift+="\t";
   // Write the comment if there is one
   if(m_comment!="")
      text+= shift+"<!-- "+m_comment+" -->\r\n";
   // Write node informations
   if(m_text!=""||m_children!=NULL){ // If it is not a single node
      // Write the name and attributes
      text += shift+"<"+m_name;
      if(m_attributes!=NULL)
         text+=m_attributes.GenerateText();
      text += ">\r\n";
      // Write the text if there is one
      if(m_text!="")
         text += shift+"\t"+m_text+"\r\n";
      // Write children
      if(m_children!=NULL)
         text+=m_children.GenerateText(depth+1);
      // Write the end
      text += shift+"</"+m_name+">\r\n";
      // Write brothers
      if(m_brothers!=NULL)
         text+=m_brothers.GenerateText(depth);
   }
   else{
      // Write the single node with attributes
      text += shift+"<"+m_name;
      if(m_attributes!=NULL)
         text+=m_attributes.GenerateText();
      text += "/>\r\n";
   }
   return text;
}
//+------------------------------------------------------------------+
//| Read the node and his sons
//| @param depth The depth of the node in the DOM
//+------------------------------------------------------------------+
void CXMLNode::ReadAll(int depth=0){
   // Put blanks before the description to represent depth
   string shift = "";
   int i;
   for(i = 0; i<depth;i++)
      shift += "-";
   // Print values
   Print(shift+"Name: "+m_name);
   if(m_text!="")
      Print(shift+"Text: "+m_text);
   // Print attribute(s)
   if(m_attributes!=NULL)
      m_attributes.ReadAll(depth);
   // Print son(s)
   if(m_children!=NULL)
      m_children.ReadAll(depth+1);
   // Print brother(s)
   if(m_brothers!=NULL)
      m_brothers.ReadAll(depth);
}
//+------------------------------------------------------------------+
//| Add an attribute to the node
//| @param name The attribute name
//| @param text The attribute text
//+------------------------------------------------------------------+
void CXMLNode::AddAttribute(string name,string text){
   this.WithoutForbiddenLetters(name);
   this.WithoutForbiddenLetters(text);
   if(m_attributes!=NULL)
      m_attributes.AddChild(name, text);
   else
      m_attributes = new CXMLAttribute(name, text);
}
//+------------------------------------------------------------------+
//| Add an attribute to the node
//| @param attribute The attribute to add
//+------------------------------------------------------------------+
void CXMLNode::AddAttribute(CXMLAttribute *attribute){   
   if(m_attributes!=NULL)
      m_attributes.AddChild(attribute);
   else
      m_attributes = attribute;
}
//+------------------------------------------------------------------+
//| Delete attributes of the node
//+------------------------------------------------------------------+
void CXMLNode::DeleteAttributes(){
   if(m_attributes!=NULL){
      delete m_attributes;
      m_attributes = NULL;
   }
}
//+------------------------------------------------------------------+
//| Get an attribute of the node by his name
//| @param name Name of the searched attribute
//| @return The attribute if it exists, NULL otherwise
//+------------------------------------------------------------------+
CXMLAttribute* CXMLNode::GetAttribute(string name){
   // Searching for the attribute
   for(CXMLAttribute* attributeTemp = m_attributes; // Get the first attribute
      attributeTemp!=NULL; // While it's not null
      attributeTemp = attributeTemp.GetChildren()){ // At each loop, get the child
      if(attributeTemp.GetName()==name) // If the name is good
         return attributeTemp; // Return the attribute
   }
   // If the program reached this point, there is no argument with this name
   return NULL;
}
//+------------------------------------------------------------------+
//| Add Child to the node
//| @param child The node to add as a child
//+------------------------------------------------------------------+
void CXMLNode::AddChild(CXMLNode *child){
   if(m_children==NULL)
      m_children = child;
   else
      m_children.AddBrother(child);
}
//+------------------------------------------------------------------+
//| Detach children from the node and return it
//| @return The child node
//+------------------------------------------------------------------+
CXMLNode* CXMLNode::DetachChildren(){
   CXMLNode* temp = NULL;
   if(m_children!=NULL){
      temp = m_children;
      m_children = NULL;
   }
   return temp;
}
//+------------------------------------------------------------------+
//| Delete first child of the node
//+------------------------------------------------------------------+
void CXMLNode::DeleteChild(){
   // Preservation of children and brothers 
   CXMLNode* children = m_children.DetachChildren();
   CXMLNode* brothers = m_children.DetachBrothers();
   delete m_children;
   m_children = brothers;
   if(m_children==NULL) // If there is no son (so no brothers)
      m_children = children;
   else
      m_children.AddBrother(children);
}
//+------------------------------------------------------------------+
//| Delete children of the node
//+------------------------------------------------------------------+
void CXMLNode::DeleteChildren(){
   if(m_children!=NULL){
      m_children.DeleteAll();
      delete m_children;
      m_children = NULL;
   }
}
//+------------------------------------------------------------------+
//| Get a child by its name
//| @param name The child name
//| @return The node if it exists, NULL otherwise
//+------------------------------------------------------------------+
CXMLNode* CXMLNode::GetChild(string name){
   for(CXMLNode* node = m_children; // Get children
      node!=NULL; // While the node is not null
      node = node.GetBrother()){ // Get the brother
      if(node.GetName()==name) // If the node name is the one researched
         return node; // Return the node
   }
   // If the process got to this part
   // It means there is no node with the name searched
   return NULL;
}
//+------------------------------------------------------------------+
//| Add a brother to the node
//| @param brother The node to add as a brother
//+------------------------------------------------------------------+
void CXMLNode::AddBrother(CXMLNode *brother){
   if(m_brothers == NULL) // If he has no little brother
      m_brothers = brother;
   else
      m_brothers.AddBrother(brother);
}
//+------------------------------------------------------------------+
//| Detach brothers from the node
//| @return The detached brother(s)
//+------------------------------------------------------------------+
CXMLNode* CXMLNode::DetachBrothers(){
   CXMLNode* temp = NULL;
   if(m_brothers != NULL){
      temp = m_brothers;
      m_brothers = NULL;
   }
   return temp;
}
//+------------------------------------------------------------------+
//| Delete brothers of the node
//+------------------------------------------------------------------+
void CXMLNode::DeleteBrothers(){
   if(m_brothers!=NULL){
      m_brothers.DeleteAll();
      delete m_brothers;
      m_brothers = NULL;
   }
}
//+------------------------------------------------------------------+
//| Get the number of brothers
//| @return The number of brothers
//+------------------------------------------------------------------+
int CXMLNode::GetBrothersNbr(){
   if(m_brothers!=NULL)
      return (1+m_brothers.GetBrothersNbr());
   else
      return 0;
}
//+------------------------------------------------------------------+
//| Get the number of children
//| @return The number of children
//+------------------------------------------------------------------+
int CXMLNode::GetChildrenNbr(){
   if(m_children!=NULL)
      return (1+m_children.GetBrothersNbr());
   else
      return 0;
}
//+------------------------------------------------------------------+
//| Get Name
//| @return The node name
//+------------------------------------------------------------------+
string CXMLNode::GetName(){
   string name = m_name;
   this.WithForbiddenLetters(name);
   return name;
}
//+------------------------------------------------------------------+
//| Get Text
//| @return The node text
//+------------------------------------------------------------------+
string CXMLNode::GetText(){
   string text = m_text;
   this.WithForbiddenLetters(text);
   return text;
}
//+------------------------------------------------------------------+
//| Get Comment
//| @return The node comment
//+------------------------------------------------------------------+
string CXMLNode::GetComment(){
   string comment = m_comment;
   this.WithForbiddenLetters(comment);
   return comment;
}
//+------------------------------------------------------------------+
//| Get Attribute
//| @return The first attribute
//+------------------------------------------------------------------+
CXMLAttribute* CXMLNode::GetAttribute(){
   return m_attributes;
}
//+------------------------------------------------------------------+
//| Get Child
//| @return The first child
//+------------------------------------------------------------------+
CXMLNode* CXMLNode::GetChild(){
   return m_children;
}
//+------------------------------------------------------------------+
//| Get Brother
//| @return The first brother
//+------------------------------------------------------------------+
CXMLNode* CXMLNode::GetBrother(){
   return m_brothers;
}
//+------------------------------------------------------------------+
//| Set name
//| @param The new name of the node
//+------------------------------------------------------------------+
void CXMLNode::SetName(string name){
   StringReplace(name, " ", "_"); // Replacement of spaces
   this.WithoutForbiddenLetters(name);
   m_name = name;
}
//+------------------------------------------------------------------+
//| Set text
//| @param The new text of the node
//+------------------------------------------------------------------+
void CXMLNode::SetText(string text){
   this.WithoutForbiddenLetters(text);
   m_text = text;
}
//+------------------------------------------------------------------+
//| Set comment
//| @param The new comment of the node
//+------------------------------------------------------------------+
void CXMLNode::SetComment(string comment){
   this.WithoutForbiddenLetters(comment);
   m_comment = comment;
}
//+------------------------------------------------------------------+
