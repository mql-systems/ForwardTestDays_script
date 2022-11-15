//+------------------------------------------------------------------+
//|                                              ForwardTestDays.mqh |
//|                            Copyright 2022. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+

//--- inputs
input datetime i_DtTestFrom   = __DATE__-2592000;  // Test from
input datetime i_DtTestTo     = __DATE__;          // Test to
input int      i_GenerateDays = 60;                // Generate days (min 10)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   //--- check inputs
   if (i_DtTestFrom >= i_DtTestTo)
   {
      Alert("Error: Incorrect time interval");
      return;
   }
   
   if ((i_DtTestTo-i_DtTestFrom) < 2592000) // 2592000 == 30 days
   {
      Alert("Error: The minimum test period is 60 working days");
      return;
   }
   
   if (i_GenerateDays < 10)
   {
      Alert("Error: The minimum number of test days is 10");
      return;
   }
   
   //--- create csv file
   string filename = "ForwardTestDays_"+TimeToString(i_DtTestFrom,TIME_DATE)+"_"+TimeToString(i_DtTestTo,TIME_DATE)+"_"+IntegerToString(TimeCurrent())+".csv";
   FileDelete(filename);
   int fileHandle = FileOpen(filename,FILE_WRITE|FILE_CSV);
   if (fileHandle == INVALID_HANDLE)
   {
      Alert("Error: creating file "+filename);
      return;
   }
   
   //--- generate and save random days
   FileWrite(fileHandle, "Date", "Result (+)", "Result (-)");
   for (int i=0; i<i_GenerateDays; i++)
      FileWrite(fileHandle, i);
   
   FileClose(fileHandle);
   
   //--- success
   Alert("Success");
}

//+------------------------------------------------------------------+
