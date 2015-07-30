//+------------------------------------------------------------------+
//|                                                 XMLAttribute.mqh |
//|                                     Copyright 2014, Louis Fradin |
//|                                      http://en.louis-fradin.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Louis Fradin"
#property link      "http://en.louis-fradin.net/"
//+------------------------------------------------------------------+
//| Prototype
//+------------------------------------------------------------------+
class CXMLAttribute{
   private:
      string m_name;
      string m_text;
      CXMLAttribute *m_children;
   public:
      CXMLAttribute();
      CXMLAttribute(string name, string text);
      ~CXMLAttribute();
      void DeleteAll();
      string GenerateText();
      void ReadAll(int depth = 0);
      // Operations on children
      void AddChild(string name, string text);
      void AddChild(CXMLAttribute *attribute);
      // Mutators
      void SetName(string name);
      void SetText(string text);
      // Accessors
      string GetName();
      string GetText();
      CXMLAttribute* GetChildren();
};
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CXMLAttribute::CXMLAttribute(){
   m_name="";
   m_text="";
   m_children = NULL;
}
//+------------------------------------------------------------------+
//| Constructor
//| @param name Name of the attribute
//| @param text Text of the attribute
//+------------------------------------------------------------------+
CXMLAttribute::CXMLAttribute(string name, string text){
   m_name=name;
   m_text=text;
   m_children = NULL;
}
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CXMLAttribute::~CXMLAttribute(){
   this.DeleteAll();
}
//+------------------------------------------------------------------+
//| Deletes children
//+------------------------------------------------------------------+
void CXMLAttribute::DeleteAll(){
   if(m_children!=NULL){
      delete m_children;
      m_children = NULL;
   }
}
//+------------------------------------------------------------------+
//| Generate Text
//| @return The generated text
//+------------------------------------------------------------------+
string CXMLAttribute::GenerateText(){
   string text = " "+m_name+"=\""+m_text+"\"";
   if(m_children!=NULL)
      text+=m_children.GenerateText();
   return text;
}
//+------------------------------------------------------------------+
//| Reads himself and children
//| @param depth The depth of the attribute in the DOM
//+------------------------------------------------------------------+
void CXMLAttribute::ReadAll(int depth = 0){
   string shift = "";
   // Creates the shift to display the depth in the tree
   for(int i = 0; i<depth;i++)
      shift += "-";
   // Prints the attribute
   Print(shift+"Attribute: "+m_name+"='"+m_text+"'");
   // Prints sons
   if(m_children!=NULL)
      m_children.ReadAll(depth);
}
//+------------------------------------------------------------------+
//| Add a child
//| @param name Name of the child attribute
//| @param text Text of the child attribute
//+------------------------------------------------------------------+
void CXMLAttribute::AddChild(string name,string text){
   if(m_children==NULL)
      m_children = new CXMLAttribute(name, text);
   else
      m_children.AddChild(name,text);
}
//+------------------------------------------------------------------+
//| Add a child
//| @param attribute The attribute to add as a child
//+------------------------------------------------------------------+
void CXMLAttribute::AddChild(CXMLAttribute *attribute){
   if(m_children==NULL)
      m_children = attribute;
   else
      m_children.AddChild(attribute);
}
//+------------------------------------------------------------------+
//| Set Name
//| @param name Name to give at the attribute
//+------------------------------------------------------------------+
void CXMLAttribute::SetName(string name){
   m_name = name;
}
//+------------------------------------------------------------------+
//| Set Text
//| @param text Text to give at the attribute
//+------------------------------------------------------------------+
void CXMLAttribute::SetText(string text){
   m_text = text;
}
//+------------------------------------------------------------------+
//| Get Name
//| @return The attribute name
//+------------------------------------------------------------------+
string CXMLAttribute::GetName(){
   return m_name;
}
//+------------------------------------------------------------------+
//| Get Text
//| @return The attribute text
//+------------------------------------------------------------------+
string CXMLAttribute::GetText(){
   return m_text;
}
//+------------------------------------------------------------------+
//| Get children
//| @return The child attribute
//+------------------------------------------------------------------+
CXMLAttribute* CXMLAttribute::GetChildren(){
   return m_children;
}
//+------------------------------------------------------------------+
