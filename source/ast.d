template DefaultConstructor()
{
    this(typeof(this.tupleof) args)
    {
        this.tupleof = args;
    }
}

template Dispatcher()
{
    auto dispatch(string method, Args...)(Command node, Args args)
    {
        import std.algorithm : castSwitch;

        return node.castSwitch!((SimpleCommand node) => mixin("this." ~ method ~ "(node, args)"),)();
    }
}

/**
 * command :==
 *      simple_command
 */
abstract class Command
{
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
