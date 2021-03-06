FancySpec describe: Block with: {
  it: "returns the value of the last expression" when: {
    block = {
      a = "a"
      empty = " "
      str = "String!"
      a ++ empty ++ str
    }
    block call is: "a String!"
  }

  it: "closes over a value and change it internally" when: {
    x = 0
    { x < 10 } while_true: {
      x is be: |x| { x < 10 }
      x = x + 1
    }
    x is: 10
  }

  it: "returns the argument count" with: 'arity when: {
    { } arity . is: 0
    |x| { } arity . is: 1
    |x y z| { } arity . is: 3
  }

  it: "calls a block while another is true" with: 'while_true: when: {
    i = 0
    {i < 10} while_true: {
      i = i + 1
    }
    i is be: { i >= 10 }
  }

  it: "calls a block while another is true or calls the alternative" with: 'while_true:else: when: {
    i = 0
    { i < 10 } while_true: {
      i = i + 1
    } else: {
      i = "nope"
    }
    i is: 10

    i = 0
    { i > 10 } while_true: {
      i = i + 1
    } else: {
      i = "nope"
    }
    i is: "nope"
  }

  it: "calls a block while another is not true (boolean false)" with: 'while_false: when: {
    i = 0
    {i == 10} while_false: {
      i = i + 1
    }
    i is: 10
  }

  # again for while_nil
  it: "calls a block while another is nil" with: 'while_nil: when: {
    i = 0
    {i == 10} while_nil: {
      i = i + 1
    }
    i is: 10
  }

  it: "calls a block while another one is true-ish" with: 'while_do: when: {
    x = 0
    { x < 10 } while_do: |val| {
      val is: true
      x = x + 1
    }
  }

  it: "calls another block while a block yields false" with: 'until_do: when: {
    i = 0
    { i > 10 } until_do: { i <= 10 is: true; i = i + 1 }
    i is: 11
  }

  it: "calls a block until another yields true" with: 'until: when: {
    i = 0
    { i <= 10 is: true; i = i + 1 } until: { i > 10 }
    i is: 11
  }

  it: "calls itself only when the argument is nil" with: 'unless: when: {
    try {
      { StdError new: "got_run!" . raise! } unless: nil
      StdError new: "didnt_run!" . raise!
    } catch StdError => e {
      e message is: "got_run!"
    }
  }

  it: "calls itself only when the argument is true" with: 'if: when: {
    try {
      { StdError new: "got_run!" . raise! } if: true
      StdError new: "didnt_run!" . raise!
    } catch StdError => e {
      e message is: "got_run!"
    }
  }

  it: "also is able to take arguments seperated by comma" with: 'call: when: {
    block = |x, y| { x + y }
    block call: [1,2] . is: 3
  }

  it: "evaluates the blocks in a short-circuiting manner" with: '&& when: {
    { false } && { false } is: false
    { true } && { false } is: false
    { false } && { true } is: false
    { true } && { true } is: true

    { false } || { false } is: false
    { false } || { true } is: true
    { true } || { false } is: true
    { true } || { true } is: true

    # TODO: Add more useful tests here...
  }

  it: "calls the block as a partial block" when: {
    [1,2,3] map: @{upto: 3} . is: [[1,2,3], [2,3], [3]]
    [1,2,3] map: @{+ 3} . is: [4,5,6]
    [1,2,3] map: @{to_s} . is: ["1", "2", "3"]
    [1,2,3] map: @{to_s * 3} . is: ["111", "222", "333"]
  }

  it: "calls the block as a partial block, converting it to implicit message sends to the first argument" when: {
    b = @{
      inspect println
      class println
      * 2 println
      'test println
    }

    require: "stringio"

    out = StringIO new
    let: '*stdout* be: out in: {
      b call: ["Hello, World"]
      b call: [1]
      b call: [1, 2, 3]
    }
    expected_output = ["\"Hello, World\"\nString\nHello, WorldHello, World\ntest\n",
                       "1\nFixnum\n2\ntest\n",
                       "[1, 2, 3]\nArray\n1\n2\n3\n1\n2\n3\ntest\n"] join
    out string is: expected_output
  }

  it: "executes a match clause if the block returns a true-ish value" with: '=== when: {
    def do_match: val {
      match val {
        case |x| { x even? } -> "yup, it's even"
        case _ -> "nope, not even"
      }
    }
    do_match: 2 . is: "yup, it's even"
    do_match: 1 . is: "nope, not even"
  }

  it: "returns the receiver of a block" with: 'receiver when: {
    class Foo { def foo { { self } } } # return block
    f = Foo new
    f foo receiver is: f
  }

  it: "sets the receiver correctly to a new value" with: 'receiver: when: {
    b = { "hey" }

    b receiver: 10
    b receiver is: 10

    b receiver: "Hello, World!"
    b receiver is: "Hello, World!"
  }

  it: "calls a block with a different receiver" with: 'call_with_receiver: when: {
    class ClassA {
      def inspect {
        "in ClassA#inspect"
      }
    }
    class ClassB {
      def inspect {
        "in ClassB#inspect"
      }
    }
    def self inspect {
      "in self#inspect"
    }
    block = {
      self inspect
    }
    block call is: "in self#inspect"
    block call_with_receiver: (ClassA new) . is: "in ClassA#inspect"
    block call_with_receiver: (ClassB new) . is: "in ClassB#inspect"
  }

  it: "calls a block with arguments and a different receiver" with: 'call:with_receiver: when: {
    class ClassC {
      def inspect: x {
        "in ClassC#inspect: #{x}"
      }
    }
    class ClassD {
      def inspect: x {
        "in ClassD#inspect: #{x}"
      }
    }
    def self inspect: x {
      "in self#inspect: #{x}"
    }
    block = |arg| {
      self inspect: arg
    }
    block call: [42] . is: "in self#inspect: 42"
    block call: [42] with_receiver: (ClassC new) . is: "in ClassC#inspect: 42"
    block call: [42] with_receiver: (ClassD new) . is: "in ClassD#inspect: 42"
  }

  it: "calls a block using []" with: '[] when: {
    b = |x y| {
      x + y
    }

    b call: [2,3] . is: 5
    b[(2,3)] . is: 5

    b2 = |x| { x * 5 }
    b2["hello"] is: ("hello" * 5)
    b2["foo"] is: (b2 call: ["foo"])
  }

  it: "dynamically creates a object with slots defined in a Block" with: 'to_object when: {
    o = {
      name: "John Connor"
      age: 12
      city: "Los Angeles"
      persecuted_by: $ {
        name: "The Terminator"
        age: 'unknown
      } to_object
    } to_object

    o name is: "John Connor"
    o age is: 12
    o city is: "Los Angeles"
    o persecuted_by do: {
      name is: "The Terminator"
      age is: 'unknown
    }
  }

  it: "dynamically creates a new object with slots recursively defined in blocks" with: 'to_object_deep when: {
    o = {
      name: "Sarah Connor"
      age: 42
      city: "Los Angeles"
      persecuted_by: {
        name: "The Terminator"
        age: 'unknown
      }
    } to_object_deep

    o name is: "Sarah Connor"
    o age is: 42
    o city is: "Los Angeles"
    o persecuted_by do: {
      name is: "The Terminator"
      age is: 'unknown
    }
  }

  it: "dynamically creates a hash with keys and values defined in a Block" with: 'to_hash when: {
    { } to_hash is: <[]>
    { foo: "bar" } to_hash is: <['foo => "bar"]>
    { foo: "bar"; bar: "baz" } to_hash is: <['foo => "bar", 'bar => "baz"]>
    h = {
      name: "John Connor"
      age: 12
      city: "Los Angeles"
      persecuted_by: $ {
        name: "The Terminator"
        age: 'unknown
      } to_hash
    } to_hash

    h is: <['name => "John Connor",
            'age => 12,
            'city => "Los Angeles",
            'persecuted_by => <[
              'name => "The Terminator",
              'age => 'unknown
            ]>
    ]>
  }

  it: "dynamically creates a hash with keys and values defined in a Block (deep)" with: 'to_hash_deep when: {
    { } to_hash_deep is: <[]>
    { foo: "bar" } to_hash_deep is: <['foo => "bar"]>
    h = {
      name: "John Connor"
      age: 12
      city: "Los Angeles"
      persecuted_by: {
        name: "The Terminator"
        age: 'unknown
      }
    } to_hash_deep

    h is: <['name => "John Connor",
            'age => 12,
            'city => "Los Angeles",
            'persecuted_by => <[
              'name => "The Terminator",
              'age => 'unknown
            ]>
    ]>
    h['persecuted_by] is: <['name => "The Terminator", 'age => 'unknown]>
  }

  it: "dynamically creates an array with values defined in a Block" with: 'to_a when: {
    { } to_a is: []
    { foo } to_a is: ['foo]
    { foo; bar; baz } to_a is: ['foo, 'bar, 'baz]
    { foo bar baz } to_a is: ['foo, 'bar, 'baz]
    {
      name: "Chris"
      age: 24
      city: "San Francisco"
      male; programmer; happy
    } to_a is: [['name, "Chris"],
                ['age, 24],
                ['city, "San Francisco"],
                'male, 'programmer, 'happy]
  }

  it: "returns a Block that calls self then a given Block" with: 'then: when: {
    a = []
    block = { a << 1 } then: { a << 2 }
    block call
    a is: [1,2]
    block call
    a is: [1,2,1,2]
  }

  it: "returns a Block that calls itself after a given Block" with: 'after: when: {
    a = []
    block = { a << 1 } after: { a << 2}
    block call
    a is: [2,1]
    block call
    a is: [2,1,2,1]
  }

  it: "calls itself while logging errors to *stderr*" with: 'call_with_errors_logged when: {
    io = StringIO new
    let: '*stderr* be: io in: {
      {
        2 / 0
      } call_with_errors_logged
    }
    io string is: "divided by 0\n"
  }

  it: "calls itself with arguments while logging errors to *stderr*" with: 'call_with_errors_logged: when: {
    io = StringIO new
    let: '*stderr* be: io in: {
      |x y| {
        2 / 0
      } call_with_errors_logged: [10, 20]
    }
    io string is: "divided by 0\n"
  }

  it: "calls itself while logging errors to a given IO object" with: 'call_with_errors_logged_to: when: {
    io = StringIO new
    {
      2 / 0
    } call_with_errors_logged_to: io
    io string is: "divided by 0\n"

    io = StringIO new
    {
      { "fail!" raise! } call_with_errors_logged_to: io
    } does_not raise: StandardError
    io string is: "fail!\n"
  }

  it: "calls itself while logging errors to a given IO object and reraising exceptions" with: 'call_with_errors_logged_to:reraise: when: {
    io = StringIO new
    {
      {
        "fail!" raise!
      } call_with_errors_logged_to: io reraise: true
    } raises: StandardError
    io string is: "fail!\n"
  }

  it: "calls itself with arguments while logging errors to a given IO object" with: 'call:with_errors_logged_to: when: {
    io = StringIO new
    {
      |x y| {
        io println: "x: #{x} y: #{y}"
        2 / 0
      } call: [10, 20] with_errors_logged_to: io
    } does_not raise: ZeroDivisionError
    io string is: "x: 10 y: 20\ndivided by 0\n"
  }

  it: "calls itself with arguments while logging errors to a given IO object and reraising exceptions" with: 'call:with_errors_logged_to:reraise: when: {
    io = StringIO new
    {
      |x y| {
        io println: "x: #{x} y: #{y}"
        2 / 0
      } call: [10, 20] with_errors_logged_to: io reraise: true
    } raises: ZeroDivisionError
    io string is: "x: 10 y: 20\ndivided by 0\n"
  }
}
