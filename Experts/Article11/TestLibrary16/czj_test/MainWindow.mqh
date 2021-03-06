//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "Program.mqh"
#include <Arrays\ArrayObj.mqh>

#define SYMBOL_CLASS_NUM 2
#define PERIOD_NUM 6
string forex_class_name[]={"USD","GBP"};
string period_string[]={"D1","M1","M5","M30","H1","H4"};
ENUM_TIMEFRAMES period_tf[]={PERIOD_D1,PERIOD_M1,PERIOD_M5,PERIOD_M30,PERIOD_H1,PERIOD_H4};
color curve_color[]={clrRed,clrOrange,clrYellow,clrGreen,clrCyan,clrBlue,clrPurple,clrBlack};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
   CWndContainer::AddWindow(m_window);
   int x=(m_window.X()>0) ? m_window.X() : 1;
   int y=(m_window.Y()>0) ? m_window.Y() : 1;

   m_window.XSize(518);
   m_window.YSize(600);
   m_window.Alpha(200);
   m_window.IconXGap(3);
   m_window.IconYGap(2);
   m_window.IsMovable(true);
   m_window.ResizeMode(true);
   m_window.CloseButtonIsUsed(true);
   m_window.FullscreenButtonIsUsed(true);
   m_window.CollapseButtonIsUsed(true);
   m_window.TooltipsButtonIsUsed(true);
   m_window.RollUpSubwindowMode(true,true);
   m_window.TransparentOnlyCaption(true);
////--- Set the tooltips
   m_window.GetCloseButtonPointer().Tooltip("Close");
   m_window.GetFullscreenButtonPointer().Tooltip("Fullscreen/Minimize");
   m_window.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
   m_window.GetTooltipButtonPointer().Tooltip("Tooltips");
//--- Creating a form
   if(!m_window.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);

   return(true);
  }
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp"
//---
bool CProgram::CreateStatusBar(const int x_gap,const int y_gap)
  {
#define STATUS_LABELS_TOTAL 2
//--- Store the pointer to the main control
   m_status_bar.MainPointer(m_window);
//--- Width
   int width[]={0,130};
//--- Properties
   m_status_bar.YSize(22);
   m_status_bar.AutoXResizeMode(true);
   m_status_bar.AutoXResizeRightOffset(1);
   m_status_bar.AnchorBottomWindowSide(true);
//--- Add items
   for(int i=0; i<STATUS_LABELS_TOTAL; i++)
      m_status_bar.AddItem(width[i]);
//--- Setting the text
   m_status_bar.SetValue(0,"For Help, press F1");
   m_status_bar.SetValue(1,"Disconnected...");
//--- Setting the icons
   m_status_bar.GetItemPointer(1).LabelXGap(25);
   m_status_bar.GetItemPointer(1).AddImagesGroup(5,3);
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp");
//--- Create a control
   if(!m_status_bar.CreateStatusBar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
  }
#resource "\\Images\\EasyAndFastGUI\\Controls\\resize_window.bmp"
//---
bool CProgram::CreatePicture1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_picture1.MainPointer(m_status_bar);
//--- Properties
   m_picture1.XSize(8);
   m_picture1.YSize(8);
   m_picture1.IconFile("Images\\EasyAndFastGUI\\Controls\\resize_window.bmp");
   m_picture1.AnchorRightWindowSide(true);
   m_picture1.AnchorBottomWindowSide(true);
//--- Creating the button
   if(!m_picture1.CreatePicture(x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_picture1);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxPeriodType(const int x_gap,const int y_gap,const string text)
  {

//--- Store the pointer to the main control
   m_period_type.MainPointer(m_window);
//--- Properties
   m_period_type.XSize(100);
   m_period_type.ItemsTotal(PERIOD_NUM);
   m_period_type.GetButtonPointer().XSize(50);
   m_period_type.GetButtonPointer().AnchorRightWindowSide(true);
//--- Populate the combo box list
   for(int i=0; i<PERIOD_NUM; i++)
      m_period_type.SetValue(i,period_string[i]);
//--- List properties
   CListView *lv=m_period_type.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 1 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_period_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_period_type);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Point type" combo box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxSymbolType(const int x_gap,const int y_gap,const string text)
  {

//--- Store the pointer to the main control
   m_symbol_type.MainPointer(m_window);
//--- Properties
   m_symbol_type.XSize(100);
   m_symbol_type.ItemsTotal(SYMBOL_CLASS_NUM);
   m_symbol_type.GetButtonPointer().XSize(50);
   m_symbol_type.GetButtonPointer().AnchorRightWindowSide(true);
//--- Populate the combo box list
   for(int i=0; i<SYMBOL_CLASS_NUM; i++)
      m_symbol_type.SetValue(i,forex_class_name[i]);
//--- List properties
   CListView *lv=m_symbol_type.GetListViewPointer();
   //lv.YSize(183);
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 0 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_symbol_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_symbol_type);
   return(true);
  }
bool CProgram::CreateTextEditPriceSize(const int x_gap,const int y_gap,const string text)
   {
    //--- Store the pointer to the main control
   m_price_size.MainPointer(m_window);
//--- Properties
   m_price_size.XSize(100);
   m_price_size.MaxValue(1000);
   m_price_size.MinValue(60);
   m_price_size.StepValue(10);
   m_price_size.SetDigits(0);
   m_price_size.SpinEditMode(true);
   m_price_size.SetValue((string)500);
   m_price_size.GetTextBoxPointer().XSize(50);
   m_price_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_price_size.GetTextBoxPointer().AnchorRightWindowSide(true);
   
   if(!m_price_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_price_size);
   return(true);
   
   }
//+------------------------------------------------------------------+
//|                创建图表                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateGraph1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_graph1.MainPointer(m_window);
//--- Properties
   m_graph1.AutoXResizeMode(true);
   m_graph1.AutoYResizeMode(true);
   m_graph1.AutoXResizeRightOffset(2);
   m_graph1.AutoYResizeBottomOffset(50);
////--- Create control
   if(!m_graph1.CreateGraph(x_gap,y_gap))
      return(false);
////--- Chart properties
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.BackgroundColor(::ColorToARGB(clrWhiteSmoke));
//
   InitGraphArrays();
////--- Create the curves 

   CCurve *data_curve[];
   ArrayResize(data_curve,fcmp.ff.GetSymbolNum());
   double price[];
   for(int i=0;i<fcmp.ff.GetSymbolNum();i++)
     {
      fcmp.GetMarketPriceAt(i,price);
      data_curve[i]=graph.CurveAdd(price,::ColorToARGB(curve_color[i]),CURVE_LINES,fcmp.ff.GetSymbolNameAt(i));
      data_curve[i].LinesWidth(2);
     }

   graph.GridBackgroundColor(clrWhiteSmoke);
   graph.GridLineColor(clrLightGray);
//--- Plot the data on the chart
   graph.CurvePlotAll();
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_graph1);
   return true;
  }
//+------------------------------------------------------------------+
//|             初始化图表数据                            |
//+------------------------------------------------------------------+
void CProgram::InitGraphArrays(void)
  {
   int period_choose=m_period_type.GetListViewPointer().SelectedItemIndex();
   int symbol_choose=m_symbol_type.GetListViewPointer().SelectedItemIndex();
   int p_num_choose=(int)m_price_size.GetValue();

   fcmp.Init(forex_class_name[symbol_choose],period_tf[period_choose],p_num_choose);
   fcmp.RefreshMarketPrice();
  }
//+------------------------------------------------------------------+
//|           更新图表                          |
//+------------------------------------------------------------------+
void CProgram::UpdateGraph(void)
  {
   InitGraphArrays();
   CGraphic *graph=m_graph1.GetGraphicPointer();

//--- Create the curves 
   for(int i=0;i<graph.CurvesTotal();i++)
     {
      double price[];
      fcmp.GetMarketPriceAt(i,price);
      CCurve *curve=graph.CurveGetByIndex(i);
      curve.Update(price);
      curve.Name(fcmp.ff.GetSymbolNameAt(i));
     }
   graph.Redraw(true);
   graph.Update();
  }
//+------------------------------------------------------------------+
//|            图形重置                                 |
//+------------------------------------------------------------------+
void CProgram::ResetGraph(void)
  {
   InitGraphArrays();
   CGraphic *graph=m_graph1.GetGraphicPointer();
   while(graph.CurvesTotal()>0)
       graph.CurveRemoveByIndex(graph.CurvesTotal()-1);

   CCurve *data_curve[];
   ArrayResize(data_curve,fcmp.ff.GetSymbolNum());
   double price[];
   for(int i=0;i<fcmp.ff.GetSymbolNum();i++)
     {
      fcmp.GetMarketPriceAt(i,price);
      data_curve[i]=graph.CurveAdd(price,::ColorToARGB(curve_color[i]),CURVE_LINES,fcmp.ff.GetSymbolNameAt(i));
      data_curve[i].LinesWidth(2);
     }
    graph.CurvePlotAll();
    graph.Redraw(true);
    graph.Update();
  }
//+------------------------------------------------------------------+
