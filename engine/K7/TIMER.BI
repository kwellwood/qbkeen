DECLARE SUB CSInstallTimer ()
DECLARE SUB CSRemoveTimer ()
DECLARE SUB CSResetTicks (BYVAL WhichTimer%)
DECLARE SUB CSSetTimer (BYVAL WhichTimer%, BYVAL Millisecs&)
DECLARE SUB CSWaitTimer (BYVAL WhichTimer%)
DECLARE FUNCTION CSElapsedTicks& (BYVAL WhichTimer%)
DECLARE FUNCTION CSTimerFlag% (BYVAL WhichTimer%)

