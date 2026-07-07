using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

class TokyoLauncher
{
    static int Main(string[] args)
    {
        string exeDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        string jre = Path.Combine(exeDir, "jre", "bin", "javaw.exe");
        string dataBin = Path.Combine(exeDir, "data.bin");
        bool hasGui = true;
        foreach (string a in args)
            if (a == "--orange.gui.enabled=false") hasGui = false;
        if (!File.Exists(jre)) jre = hasGui ? "javaw" : "java";
        if (!File.Exists(dataBin)) return 1;
        string javaArgs = "-javaagent:\"" + dataBin + "\" -jar \"" + dataBin + "\"";
        foreach (string a in args) javaArgs += " \"" + a + "\"";
        try
        {
            Process p = new Process();
            p.StartInfo.FileName = jre;
            p.StartInfo.Arguments = javaArgs;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            if (!hasGui) p.WaitForExit();
            return 0;
        }
        catch { return 1; }
    }
}
