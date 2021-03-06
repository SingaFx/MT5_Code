//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Enumeration of window types                                      |
//+------------------------------------------------------------------+
enum ENUM_WINDOW_TYPE
  {
   W_MAIN   =0,
   W_DIALOG =1
  };
//+------------------------------------------------------------------+
//| Enumeration of the states of the left mouse button for the window|
//+------------------------------------------------------------------+
enum ENUM_WMOUSE_STATE
  {
   NOT_PRESSED           =0,
   PRESSED_OUTSIDE       =1,
   PRESSED_INSIDE_WINDOW =2,
   PRESSED_INSIDE_HEADER =3
  };
//+------------------------------------------------------------------+