import std.stdio : stdin, write;
import eval : Evaluator;
import parser : Parser;

void main()
{
    const prompt = "nosh % ";

    auto parser = new Parser(stdin);
    auto evaluator = new Evaluator();

    while (!parser.eof)
    {
        // プロンプトを表示する
        write(prompt);

        // 入力を構文解析する
        auto command = parser.parse();

        if (command !is null)
        {
            evaluator.run(command);
        }
    }
}
