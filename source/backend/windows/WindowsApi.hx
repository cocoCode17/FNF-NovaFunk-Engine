package backend.windows;

#if windows
@:cppFileCode('
#include <windows.h>
#include <dwmapi.h>
#pragma comment(lib, "dwmapi.lib")

typedef HRESULT (WINAPI *pfnDwmSetWindowAttribute)(HWND hwnd, DWORD dwAttribute, LPCVOID pvAttribute, DWORD cbAttribute);
')
#end
class WindowsApi
{
	public static function enableDarkMode():Void
	{
		#if windows
		setDarkModeCPP();
		#end
	}

	#if windows
	@:functionCode('
		HWND hwnd = GetActiveWindow();
		if (hwnd == NULL)
		{
			hwnd = GetForegroundWindow();
		}

		if (hwnd != NULL)
		{
			HMODULE hDwm = LoadLibraryA("dwmapi.dll");
			if (hDwm != NULL)
			{
				pfnDwmSetWindowAttribute setAttr = (pfnDwmSetWindowAttribute)GetProcAddress(hDwm, "DwmSetWindowAttribute");
				if (setAttr != NULL)
				{
					BOOL useDarkMode = TRUE;

					HRESULT hr = setAttr(hwnd, 20, &useDarkMode, sizeof(useDarkMode));
					
					if (FAILED(hr))
					{
						hr = setAttr(hwnd, 19, &useDarkMode, sizeof(useDarkMode));
					}
				}
				FreeLibrary(hDwm);
			}
		}
	')
	private static function setDarkModeCPP():Void
	{
	}
	#end
}