import std.process : ProcessException, spawnProcess, wait;
import std.stdio : stderr, stdin, write;
import parser : Parser;

// コマンドを実行する
void execute(string[] args)
{
    try
    {
        spawnProcess(args).wait();
    }
    catch (ProcessException e)
    {
        stderr.writeln(e.message);
    }
}

void main()
{
    const prompt = "nosh % ";

    auto parser = new Parser(stdin);

    while (!parser.eof)
    {
        // プロンプトを表示する
        write(prompt);

        // 入力を構文解析する
        auto args = parser.parse();

        if (args.length > 0)
        {
            // 解析結果のコマンドを実行する
            execute(args);
        }
    }
}
