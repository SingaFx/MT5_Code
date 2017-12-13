//+------------------------------------------------------------------+
//|                                                         Tab3.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
#define TAB3_SYMBOL_CLASS_NUM 3
int tab_corr_index=2;//元素在tab中的索引位置
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_CLASS
  {
   MARKET_TOTAL_SYMBOLS,
   MARKET_SELECT_SYMBOLS,
   CUSTOMER_DEFINE_SYMBOLS
  };
string customer_symbols[]={"GBPUSD","EURUSD","USDJPY","XAUUSD"};
string symbol_class_string[]={"Total","Select","Custom"};
//+------------------------------------------------------------------+
//|            TAB3 创建复选框--品种类别选择                               |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3ComboBoxSymbolType(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   tab3_symbols_type.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_symbols_type);
//--- Properties
   tab3_symbols_type.XSize(100);
   tab3_symbols_type.ItemsTotal(TAB3_SYMBOL_CLASS_NUM);
   tab3_symbols_type.GetButtonPointer().XSize(50);
   tab3_symbols_type.GetButtonPointer().AnchorRightWindowSide(true);

//--- Populate the combo box list
   for(int i=0; i<TAB3_SYMBOL_CLASS_NUM; i++)
      tab3_symbols_type.SetValue(i,symbol_class_string[i]);
//--- List properties
   CListView *lv=tab3_symbols_type.GetListViewPointer();
//lv.YSize(183);
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 0 : lv.SelectedItemIndex());
//--- Create a control
   if(!tab3_symbols_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,tab3_symbols_type);
   return(true);
  }

#define TAB3_PERIOD_NUM 6
ENUM_TIMEFRAMES tab3_time_frame[]={PERIOD_M1,PERIOD_M5,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
string tab3_period_string[]={"M1","M5","M30","H1","H4","D1"};
//+------------------------------------------------------------------+
//|            TAB3创建复选框--周期选择                                    |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3ComboBoxPeriodType(const int x_gap,const int y_gap,const string text)
  {
   tab3_period_type.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_period_type);

   tab3_period_type.XSize(100);

   tab3_period_type.ItemsTotal(TAB3_PERIOD_NUM);
   tab3_period_type.GetButtonPointer().XSize(50);
   tab3_period_type.GetButtonPointer().AnchorRightWindowSide(true);

   for(int i=0; i<TAB3_PERIOD_NUM; i++)
      tab3_period_type.SetValue(i,tab3_period_string[i]);

   CListView *lv=m_period_type.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 1 : lv.SelectedItemIndex());
//--- Create a control
   if(!tab3_period_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,tab3_period_type);
   return(true);
  }
bool CProgram::CreateTab3ButtonsGroupDataRange(const int x_gap,const int y_gap,const string text)
   {
    tab3_data_range.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_data_range);
   int buttons_y_offset[]={5,48,88};
   string buttons_text[]={"Fix Time","Dynamic","Fix Num."};
   tab3_data_range.ButtonYSize(14);
   tab3_data_range.IsCenterText(true);
   tab3_data_range.RadioButtonsMode(true);
   tab3_data_range.RadioButtonsStyle(true);
//--- Add buttons to the group
   for(int i=0; i<3; i++)
      tab3_data_range.AddButton(0,buttons_y_offset[i],buttons_text[i],70);
//--- Create a group of buttons
   if(!tab3_data_range.CreateButtonsGroup(x_gap,y_gap))
      return(false);
//--- Highlight the second button in the group
   tab3_data_range.SelectButton(2);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,tab3_data_range);
   return(true);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3CalendarFrom(const int x_gap,const int y_gap,const string text)
  {
   tab3_calendar_from.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_calendar_from);
   if(!tab3_calendar_from.CreateDropCalendar(text,x_gap,y_gap))
      return false;
   tab3_calendar_from.SelectedDate(D'2017.01.01');
   CWndContainer::AddToElementsArray(0,tab3_calendar_from);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3CalendarTo(const int x_gap,const int y_gap,const string text)
  {
   tab3_calendar_to.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_calendar_to);
   if(!tab3_calendar_to.CreateDropCalendar(text,x_gap,y_gap))
      return false;
   tab3_calendar_to.SelectedDate(TimeCurrent()-(int)MathMod(TimeCurrent(),24*60*60));
   CWndContainer::AddToElementsArray(0,tab3_calendar_to);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3CalendarBegin(const int x_gap,const int y_gap,const string text)
  {
   tab3_calendar_begin.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_calendar_begin);
   if(!tab3_calendar_begin.CreateDropCalendar(text,x_gap,y_gap))
      return false;
   tab3_calendar_begin.SelectedDate(D'2017.01.01');
   CWndContainer::AddToElementsArray(0,tab3_calendar_begin);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TimeEditFrom(const int x_gap,const int y_gap,const string text)
  {
   tab3_edit_from.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_edit_from);
   if(!tab3_edit_from.CreateTimeEdit(text,x_gap,y_gap))
      return false;
   tab3_edit_from.XGap(x_gap+7);
   tab3_edit_from.SetHours(0);
   tab3_edit_from.SetMinutes(0);
   CWndContainer::AddToElementsArray(0,tab3_edit_from);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TimeEditTo(const int x_gap,const int y_gap,const string text)
  {
   tab3_edit_to.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_edit_to);
   if(!tab3_edit_to.CreateTimeEdit(text,x_gap,y_gap))
      return false;
   tab3_edit_to.XGap(x_gap+7);
   tab3_edit_to.SetHours(0);
   tab3_edit_to.SetMinutes(0);
   CWndContainer::AddToElementsArray(0,tab3_edit_to);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TimeEditBegin(const int x_gap,const int y_gap,const string text)
  {
   tab3_edit_begin.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_edit_begin);
   if(!tab3_edit_begin.CreateTimeEdit(text,x_gap,y_gap))
      return false;
   tab3_edit_begin.XGap(x_gap+7);
   tab3_edit_begin.SetHours(0);
   tab3_edit_begin.SetMinutes(0);
   CWndContainer::AddToElementsArray(0,tab3_edit_begin);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TextEditFixNum(const int x_gap,const int y_gap,const string text)
  {
   tab3_fix_num.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,m_fix_num);

//--- Properties
   tab3_fix_num.XSize(100);
   tab3_fix_num.MaxValue(1000);
   tab3_fix_num.MinValue(60);
   tab3_fix_num.StepValue(10);
   tab3_fix_num.SetDigits(0);
   tab3_fix_num.SpinEditMode(true);
   tab3_fix_num.SetValue((string)500);
   tab3_fix_num.GetTextBoxPointer().XSize(50);
   tab3_fix_num.GetTextBoxPointer().AutoSelectionMode(true);
   tab3_fix_num.GetTextBoxPointer().AnchorRightWindowSide(true);

   if(!tab3_fix_num.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,tab3_fix_num);
   return(true);

  }
bool CProgram::CreateTab3CorrTable(const int x_gap,const int y_gap)
   {
    tab3_corr_table.MainPointer(m_tabs1);
    m_tabs1.AddToElementsArray(2,tab3_corr_table);
    string table_title[]={"symbol-1","symbol-2","M1","M5","M30","H1","H4","D1","Res"};
    tab3_corr_table.TableSize(ArraySize(table_title),100);
    tab3_corr_table.CellYSize(40);
    //tab3_corr_table.CellColor(clrYellow);
    
    
    //tab3_corr_table.ColumnResizeMode(true);
    //tab3_corr_table.AnchorRightWindowSide(true);
    tab3_corr_table.AutoXResizeMode(true);
    tab3_corr_table.AutoYResizeMode(true);
    tab3_corr_table.AutoXResizeRightOffset(10);
    tab3_corr_table.AutoYResizeBottomOffset(10);
    tab3_corr_table.ShowHeaders(true);
    for(int i=0;i<ArraySize(table_title);i++)
      {
       tab3_corr_table.SetHeaderText(i,table_title[i]);
      }
    tab3_corr_table.HeadersColor(clrGreenYellow);
    if(!tab3_corr_table.CreateTable(x_gap,y_gap))
        return false;
    CWndContainer::AddToElementsArray(0,tab3_corr_table);  
    return true; 
   }
CForexMarketDataAnalyzier *CProgram::GetCorrData(void)
   {
    int symbol_choose=m_symbol_type.GetListViewPointer().SelectedItemIndex();
    CForexMarketDataManager *dm=new CForexMarketDataManager();
    dm.SetParameter()
   }
//+------------------------------------------------------------------+
