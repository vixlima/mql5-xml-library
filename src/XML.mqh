//+------------------------------------------------------------------+
//|                                                          XML.mqh |
//|                                     Copyright 2014, Louis Fradin |
//|                                      http://en.louis-fradin.net/ |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2014, Louis Fradin"
#property link          "http://en.louis-fradin.net/"
#property description   "XML Document creator and parser"
// Includes
#include "XMLNode.mqh"
//+------------------------------------------------------------------+
//| Prototype
//+------------------------------------------------------------------+
class CXML{
   protected:
      CXMLNode *m_root; // Root of the tree
      // Parse functions
      int ParseNode(CXMLNode *node, string text, int position = 0); // Parsing a text and put it into a node
      int ParseAttribute(CXMLNode *node, string text, int position); // Parsing a text and put it into attribute
      int ParseContent(CXMLNode* node, string text, int position); // Parsing a text and put it into the node content
      // Other functions
      string GenerateText(); // Generate a string with the tree
   public:
      CXML(); // Constructor
      ~CXML(); // Destructor
      void Clear(); // Clear the tree
      void ReadDOM(); // Read the Tree
      bool ReadFromFile(string fileName, string extension = "xml"); // Read the file to extract the tree
      bool Save(string fileName, string extension = "xml"); // Save the tree into a xml file
      // Accessors
      CXMLNode* GetDocumentRoot(); // Get the tree root   
      // Mutators
      bool SetDocumentRoot(CXMLNode* root); // Set the tree by the root entered
};
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CXML::CXML(){
   m_root = NULL; // Setting the root to nothing
}
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CXML::~CXML(){
   if(m_root!=NULL)
      delete m_root;
}
//+------------------------------------------------------------------+
//| Parse a text into a node
//| @param *node Pointer on a initialised node
//| @param text Text to analyse
//| @param position Position in the text where the parsing should begin
//| @return Position where the analyse stopped
//+------------------------------------------------------------------+
int CXML::ParseNode(CXMLNode *node, string text, int position = 0){
   string character, name;
   int state, maxSize;
   state = 0;
   maxSize = StringLen(text);
   name = "";
   while(state!=5&&position<maxSize){
      character = StringSubstr(text,position,1);
      switch(state){
         case 0: // Initial state
            if(character=="<")
               state = 1;
            break;
         case 1: // Beginning of the name capture
            if(character!=" "&&character!="\t"){
               state = 2;
               node.SetName(character);
            }
            break;
         case 2: // Full name capture
            if(character == " ")
               state = 3;
            else if(character == "/")
               state = 4;
            else if(character == ">")
               state = 6;
            else
               node.SetName(node.GetName()+character);
            break;
         case 3: // Recover the arguments
            position = ParseAttribute(node, text, position);
     
            character = StringSubstr(text,position,1);
            if(character == "/")
               state = 4;
            else if (character == ">")
               state = 6; 
            break;
         case 4:
            if(character == ">")
               state = 5;
            break;
         case 6:
            position = ParseContent(node, text, position);
            state = 5;
            break;
         default:
            break;
      }
      position++;
   }
   return (position-1);
}
//+------------------------------------------------------------------+
//| Parse a text into attribute
//| @param *node Pointer on a initialised node
//| @param text Text to analyse
//| @param position Position in the text where the parsing should begin
//| @return Position where the analyse stopped
//+------------------------------------------------------------------+
int CXML::ParseAttribute(CXMLNode *node, string text, int position){
   // Variables creation
   int state, maxSize;
   string character, aName, aText;
   CXMLAttribute *attribute;
   // Variables initialisation
   aName = "";
   aText = "";
   state = 0;
   attribute = NULL;
   maxSize = StringLen(text);
   while(state!=11&&position<maxSize){
      character = StringSubstr(text,position,1);
      switch(state){
         case 0:
            if(character == ">" || StringSubstr(text,position,2) == "/>")
               state = 10;
            else if(character != " "){
               aName += character;          
               state = 1;
            }
            break;
         case 1:
            if(character == " ")
               state = 2;
            else if(character == "=")
               state = 3;
            else
               aName += character;
            break;
         case 2:
            if(character=="=")
               state = 3;
            else if(character!=" ")
               state = 9;
            break;
         case 3:
            if(character=="'")
               state = 4;
            else if(character=="\"")
               state = 5;
            else if(character!=" "){
               aText+=character;
               state = 6;
            }
            break;
         case 4:
            if(character=="'")
               state = 9;
            else
               aText+=character;
            break;
         case 5:
            if(character=="\"")
               state = 9;
            else
               aText+=character;
            break;
         case 6:
            if(character==" ")
               state = 9;
            else
               aText+=character;
            break;
         case 9:
            position--; // This state doesn't treat a character
            if(attribute == NULL)
               attribute = new CXMLAttribute(aName, aText);
            else
               attribute.AddChild(aName, aText);             
            aName = "";
            aText = "";
            state = 0;
            break;
         case 10:
            position--;
            state = 11;
            
            break;
         default:
            break;
      }
      
      position++;
   }
   if(aName!=""||aText!=""){ // If there is still an argument
      if(attribute == NULL)
         attribute = new CXMLAttribute(aName, aText);
      else
         attribute.AddChild(aName, aText);
   }
   node.AddAttribute(attribute);
   return (position-1);
}
//+------------------------------------------------------------------+
//| Parse a text into a node content
//| @param *node Pointer on a initialised node
//| @param text Text to analyse
//| @param position Position in the text where the parsing should begin
//| @return Position where the analyse stopped
//+------------------------------------------------------------------+
int CXML::ParseContent(CXMLNode* node, string text, int position){
   int state, maxSize, nameSize, spacesNbr;
   string character, temp, nodeText;
   CXMLNode *child;
   nameSize = StringLen(node.GetName());
   state = 0;
   spacesNbr = 0;
   nodeText = "";
   maxSize = StringLen(text);
   while(state!=6&&position<maxSize){
      character = StringSubstr(text,position,1);
      switch(state){
         case 0:
            if(character == "<")
               state = 1;
            else if(character != " "&&character != "\t"){
               nodeText += character;
               spacesNbr = 0;
               state = 4;
            }
            else
               spacesNbr++;
            break;
         case 1 :
            if(character=="/")
               state = 2;
            else{
               position-=2;
               state = 5;
            }
            break;
         case 2:
            temp = StringSubstr(text, position, nameSize+1);
            
            if(temp == node.GetName()+" "){
               position += nameSize;
               state = 3;
            }
            else if(temp == node.GetName()+">"){
               position += nameSize-1;
               state = 3;
            }
            else{
               nodeText += "<"+character;
               state = 0;
            }
            break;
         case 3:
            if(character==">")
               state = 6;
            break;
         case 4:
            if(character == "<")
               state = 1;
            else{
               if(character == " " || character == "\t")
                  spacesNbr++;
               else
                  spacesNbr=0;
               nodeText += character;
            }
            break;
         case 5:
            child = new CXMLNode();
            position = ParseNode(child, text, position);
            node.AddChild(child);
            child = NULL;
            state = 0;
            break;
         default:
            break;
      }
      position++;
   }
   int textSize = StringLen(nodeText);
   nodeText = StringSubstr(nodeText, 0, textSize - spacesNbr);
   node.SetText(nodeText);
   return (position-1);
}
//+------------------------------------------------------------------+
//| Clear the root node
//+------------------------------------------------------------------+
void CXML::Clear(){
   if(m_root!=NULL){
      m_root.DeleteAll();
      delete m_root;
      m_root = NULL;
   }
}
//+------------------------------------------------------------------+
//| Read the DOM from the root node
//+------------------------------------------------------------------+
void CXML::ReadDOM(){
   if(m_root!=NULL)
      m_root.ReadAll();
   else
      Print("XML::ReadDom: The document root is empty.");
}
//+------------------------------------------------------------------+
//| Generate Text from the node root
//| @return Text generated
//+------------------------------------------------------------------+
string CXML::GenerateText(){
   return m_root.GenerateText();
}
//+------------------------------------------------------------------+
//| Read From File
//| @param fileName Name of the file
//| @param extension Extension of the file
//| @return true if successful, false otherwise
//+------------------------------------------------------------------+
bool CXML::ReadFromFile(string fileName,string extension="xml"){
   string fullName = fileName + "." + extension;
   // If the file doesn't exists
   if(!FileIsExist(fullName)){
      Print("XML::ReadFromFile: The file "+fullName+" doesn't exist");
      return false;
   }
   // Open the file
   int handle = FileOpen(fullName, FILE_READ|FILE_TXT, 0, CP_UTF8);
   if(handle==INVALID_HANDLE){
      Print("XML::ReadFromFile: Error during the opening of "+fullName);
      return false;
   }
   // Reading the File Content
   string fileContent="";
   while(!FileIsEnding(handle)){
      fileContent += FileReadString(handle);
   }
   // Eliminate comments from the text
   int pos1, pos2;
   for(pos1 = 0; pos1 != -1; pos2 = 0){
      // Find a comment
      pos1 = StringFind(fileContent, "<!--");
      if(pos1!=-1){ // If there is a comment
         pos2 = StringFind(fileContent, "-->", pos1); // Search the end of the comment
         if(pos2!=-1) // If there is an end
            pos2+=3; // +3 for "-->"
         else 
            pos2 = pos1 + 4; // +4 for "<!--"
         // Take what is not between pos1 and pos2 = Everything except the comment
         fileContent = StringSubstr(fileContent, 0, pos1) + StringSubstr(fileContent, pos2);
      }
   }
   // Verification of the state of the root node
   if(m_root!=NULL)
      this.Clear();
   else
      m_root = new CXMLNode();
   // Parsing the text
   this.ParseNode(m_root, fileContent);
   return true;
}
//+------------------------------------------------------------------+
//| Save File
//| @param fileName Name of the file
//| @param extension Extension of the file
//| @return true if successful, false otherwise
//+------------------------------------------------------------------+
bool CXML::Save(string fileName, string extension = "xml"){
   string fullName = fileName + "." + extension;
   // If the file exists, it is deleted
   if(FileIsExist(fullName)){
      if(!FileDelete(fullName)){
         Print("XML::Save: Impossible to delete file "+fullName);
         return false;
      }
   }
   // Open the file
   int handle = FileOpen(fullName, FILE_WRITE|FILE_TXT, 0, CP_UTF8);
   if(handle==INVALID_HANDLE){
      Print("XML::Save: Error during the opening of "+fullName);
      return false;
   }
   if(FileWriteString(handle,this.GenerateText())<=0){
      Print("XML::Save: Error during the writing of the code in "+fullName);
      FileClose(handle);
      return false;
   }
   FileClose(handle);
   return true;
}
//+------------------------------------------------------------------+
//| GetDocumentRoot
//| @return The root node
//+------------------------------------------------------------------+
CXMLNode* CXML::GetDocumentRoot(){
   return m_root;
}
//+------------------------------------------------------------------+
//| SetDocumentRoot
//| @param The node to set as root
//| @return true if the root has no brother, false otherwise
//+------------------------------------------------------------------+
bool CXML::SetDocumentRoot(CXMLNode *root){
   if(root==NULL){
      Print("XML::SetDocumentRoot: The node is NULL");
      return false;
   }
   else if(root.GetBrothersNbr()>1){ // If the root has a brother
      Print("XML::SetDocumentRoot : The document root must be the only node at the base");
      return false;
   }
   if(m_root!=NULL){
      this.Clear();
      delete m_root;
   }
   m_root = root;
   return true;
}
//+------------------------------------------------------------------+
