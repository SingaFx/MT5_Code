//+------------------------------------------------------------------+
//|                                                         Tab3.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Create button to call the color picker 1                         |
//+------------------------------------------------------------------+
bool CProgram::CreateGridLineColor(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_grid_line_color.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,m_grid_line_color);
//--- Properties
   m_grid_line_color.XSize(200);
   m_grid_line_color.YSize(20);
   m_grid_line_color.IconYGap(2);
   m_grid_line_color.CurrentColor(m_graph1.GetGraphicPointer().GridLineColor());
   m_grid_line_color.GetButtonPointer().XSize(95);
   m_grid_line_color.GetButtonPointer().AnchorRightWindowSide(true);
//--- Create control
   if(!m_grid_line_color.CreateColorButton(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_grid_line_color);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button to call the color picker 1                         |
//+------------------------------------------------------------------+
bool CProgram::CreateGridAxisLineColor(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_grid_axis_line_color.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,m_grid_axis_line_color);
//--- Properties
   m_grid_axis_line_color.XSize(200);
   m_grid_axis_line_color.YSize(20);
   m_grid_axis_line_color.IconYGap(2);
   m_grid_axis_line_color.CurrentColor(m_graph1.GetGraphicPointer().GridAxisLineColor());
   m_grid_axis_line_color.GetButtonPointer().XSize(95);
   m_grid_axis_line_color.GetButtonPointer().AnchorRightWindowSide(true);
//--- Create control
   if(!m_grid_axis_line_color.CreateColorButton(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_grid_axis_line_color);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button to call the color picker 1                         |
//+------------------------------------------------------------------+
bool CProgram::CreateGridBackColor(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_grid_back_color.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,m_grid_back_color);
//--- Properties
   m_grid_back_color.XSize(200);
   m_grid_back_color.YSize(20);
   m_grid_back_color.IconYGap(2);
   m_grid_back_color.CurrentColor(m_graph1.GetGraphicPointer().GridBackgroundColor());
   m_grid_back_color.GetButtonPointer().XSize(95);
   m_grid_back_color.GetButtonPointer().AnchorRightWindowSide(true);
//--- Create control
   if(!m_grid_back_color.CreateColorButton(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_grid_back_color);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Grid has circle" checkbox                            |
//+------------------------------------------------------------------+
bool CProgram::CreateGridHasCircle(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_grid_has_circle.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,m_grid_has_circle);
//--- Properties
   m_grid_has_circle.XSize(200);
   m_grid_has_circle.YSize(14);
   m_grid_has_circle.IsPressed(m_graph1.GetGraphicPointer().GridHasCircle());
//--- Create a control
   if(!m_grid_has_circle.CreateCheckBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_grid_has_circle);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Grid circle radius" edit box                         |
//+------------------------------------------------------------------+
bool CProgram::CreateGridCircleRadius(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_grid_circle_radius.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(2,m_grid_circle_radius);
//--- Properties
   m_grid_circle_radius.XSize(200);
   m_grid_circle_radius.MaxValue(20);
   m_grid_circle_radius.MinValue(0);
   m_grid_circle_radius.StepValue(1);
   m_grid_circle_radius.SetDigits(0);
   m_grid_circle_radius.SpinEditMode(true);
   m_grid_circle_radius.SetValue((string)m_graph1.GetGraphicPointer().GridCircleRadius());
   m_grid_circle_radius.GetTextBoxPointer().XSize(95);
   m_grid_circle_radius.GetTextBoxPointer().AutoSelectionMode(true);
   m_grid_circle_radius.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_grid_circle_radius.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_grid_circle_radius);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button to call the color picker 1                         |
//+------------------------------------------------------------------+
bool CProgram::CreateGridCircleColor(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_grid_circle_color.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,m_grid_circle_color);
//--- Properties
   m_grid_circle_color.XSize(200);
   m_grid_circle_color.YSize(20);
   m_grid_circle_color.IconYGap(2);
   m_grid_circle_color.CurrentColor(m_graph1.GetGraphicPointer().GridBackgroundColor());
   m_grid_circle_color.GetButtonPointer().XSize(95);
   m_grid_circle_color.GetButtonPointer().AnchorRightWindowSide(true);
//--- Create control
   if(!m_grid_circle_color.CreateColorButton(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_grid_circle_color);
   return(true);
  }  
//+------------------------------------------------------------------+
