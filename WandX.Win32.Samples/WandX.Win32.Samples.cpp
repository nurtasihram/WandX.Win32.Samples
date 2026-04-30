#include "WandX.h"
#include "WandX.Win32.Console.h"

int WxMain() {
	Console.Write("WX - Tests\n");
	Console.Write(Console.OriginalTitleA());
	//MsgBox(T("WX - Tests"), T("Hello, World!"));
	//StringA str((size_t)13);
	//str.Copy("Hello, World!");
	return 0;
}
