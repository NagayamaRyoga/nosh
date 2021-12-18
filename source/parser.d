import std.algorithm : filter;
import std.array : array, split;
import std.stdio : File;
import std.string : chomp;

class Parser
{
    private File _in;
    private string _buffer;

    this(File input)
    {
        _in = input;
        _buffer = null;
    }

    bool eof() const
    {
        return _in.eof;
    }

    /**
     * 入力を構文解析する
     *
     * input :==
     *      <command_line>
     *
     * command_line :==
     *      <command> '\n'
     *
     * command :==
     *      (\s* <word>)*
     */
    string[] parse()
    {
        _buffer = readln();
        auto args = _buffer.chomp.split(" ").filter!"!a.empty".array;
        return args;
    }

    private string readln()
    {
        return _in.readln();
    }
}
