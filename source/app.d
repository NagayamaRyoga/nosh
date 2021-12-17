import std.array : split;
import std.process : ProcessException, spawnProcess, wait;
import std.stdio : readln, stderr, write;
import std.string : chomp;

// コマンド文字列を受け取り、スペースで分割する
string[] parse(string line)
{
    auto args = line.chomp.split(" ");
    return args;
}

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

    for (;;)
    {
        // プロンプトを表示する
        write(prompt);

        // 標準入力から一行読み込む
        const line = readln();
        if (line == null)
        {
            break;
        }

        // 入力を構文解析する
        auto args = parse(line);

        if (args.length > 0)
        {
            // 解析結果のコマンドを実行する
            execute(args);
        }
    }
}
