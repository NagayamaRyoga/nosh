template DefaultConstructor()
{
    this(typeof(this.tupleof) args)
    {
        this.tupleof = args;
    }
}

template Dispatcher()
{
    auto dispatch(string method, Args...)(Command node, auto ref Args args)
    {
        import std.algorithm : castSwitch;

        return node.castSwitch!((PipeCommand node) => mixin("this." ~ method ~ "(node, args)"),
                (SimpleCommand node) => mixin("this." ~ method ~ "(node, args)"),)();
    }
}

/**
 * command :==
 *      pipe_command
 *      simple_command
 */
abstract class Command
{
}

/**
 * pipe_command :==
 *      command '|' command
 */
class PipeCommand : Command
{
    mixin DefaultConstructor;

    Command left, right;
}

/**
 * simple_command :==
 *      command_element+
 */
class SimpleCommand : Command
{
    mixin DefaultConstructor;

    CommandElement[] elements;
}

/**
 * command_element :==
 *      word+
 */
class CommandElement
{
    mixin DefaultConstructor;

    Word[] words;
}

/**
 * word :==
 *      WORD
 */
class Word
{
    mixin DefaultConstructor;

    string text;
}
