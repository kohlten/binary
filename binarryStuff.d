import std.datetime : Duration, MonoTime;
import std.stdio : writeln;
import std.bigint;

struct BaseNumber
{
	byte[] num;
	int bits;
	int base;
	bool signed;

	string toString()
	{
		string output;

		foreach (digit; this.num)
			output ~= digit + 48;
		return output;
	}

	long toLong()
	{
		long output;

		foreach (digit; this.num)
		{
			output += digit;
			output *= 10;
		}
		return output;
	}

	BigInt toBigInt()
	{
		return BigInt(this.toString());
	}
}

V[] insert(V)(V[] items, V newItem, ulong pos)
{
	items.length += 1;
	for (ulong i = items.length - 1; i > pos; i--)
		items[i] = items[i - 1];
	items[pos] = newItem;
	return items;
}

unittest
{
	import std.random : uniform;
	writeln("insert test");
	int[] arr;
	foreach (i; 0 .. 10)
		arr ~= uniform(0, 50);
	int[] newArr = arr;
	newArr.insert(uniform(0, 50), 0);

}

T[] revArray(T)(T[] arr)
{
	T tmp;
	ulong i;
	ulong j = arr.length - 1;
	while (i < arr.length / 2)
	{
		tmp = arr[i];
		arr[i] = arr[j];
		arr[j] = tmp;
		i++;
		j--;
	}
	return arr;
}


BaseNumber convToBase(T)(T num, byte base = 2)
{
	static BaseNumber outNum;

	if (num == 0)
	{
		outNum.bits--;
		outNum.num = revArray(outNum.num);
		BaseNumber tmp = outNum;
		outNum.bits = 0;
		outNum.num.length = 0;
		return tmp;
	}
	ubyte b = cast(ubyte)(num % base);
	outNum.num ~= b;
	num /= base;
	outNum.bits++;
	return convToBase(num, base);
}

T power(T)(T x, T y)
{
	T temp;
    if( y == 0)
        return 1;
    temp = power(x, y/2);
    if (y%2 == 0)
        return temp*temp;
    else
        return x*temp*temp;
}

unittest
{
	import std.math : pow;
	writeln("Power func");
	foreach (i; 0 .. 100)
	{
		float one = pow(2, i);
		float two = power(2, i);
		assert(one == two);
	}
	writeln("Power done");
}

V convToDecimal(V)(BaseNumber num, int base = 2)
{
	static V outNum;
	static i = 0;

	if (i == num.num.length)
	{
		V tmp = outNum;
		outNum = 0;
		i = 0;
		return tmp;
	}
	outNum += (num.num[i] * power(base, num.bits));
	num.bits--;
	i++;
	return convToDecimal!V(num, base);
}

unittest
{
	import std.random : uniform;
	writeln("Convertion to decimal!");

	assert(convToDecimal!ulong(BaseNumber([1, 0, 1, 0, 1, 0], 5, 101010)) == 42);
	foreach (i; 0 .. 500)
	{
		int num = uniform(0, 1000000);
		assert(convToDecimal!ulong(convToBase(num)) == num);
	}
	writeln("Done decimal");
}

V or(T, V = ulong)(T a, T b)
{
	BaseNumber output;
	BaseNumber num1;
	BaseNumber num2;
	static if (!is(a : BaseNumber))
	{
		num1 = convToBase(a);
		num2 = convToBase(b);
	}
	while (num1.num.length != num2.num.length)
	{
		if (num1.num.length < num2.num.length)
			num1.num = num1.num.insert(0, 0);
		else
			num2.num = num2.num.insert(0, 0);
	}
	foreach_reverse (i; 0 .. num1.num.length)
	{
		if (num1.num[i] || num2.num[i])
			output.num ~= 1;
		else
			output.num ~= 0;
	}
	return convToDecimal!V(output);
}

unittest
{
	import std.random : uniform;
	writeln("Or test");
	foreach (i; 0 .. 100)
	{
		auto num1 = uniform(0, 100);
		auto num2 = uniform(0, 100);
		assert(or(num1, num2) == (num1 | num2));
	}
	writeln("Or done");
}

V and(T, V = ulong)(T a, T b)
{
	BaseNumber output;
	BaseNumber num1;
	BaseNumber num2;
	static if (!is(a : BaseNumber))
	{
		num1 = convToBase(a);
		num2 = convToBase(b);
	}
	while (num1.num.length != num2.num.length)
	{
		if (num1.num.length < num2.num.length)
			num1.num = num1.num.insert(0, 0);
		else
			num2.num = num2.num.insert(0, 0);
	}
	foreach_reverse (i; 0 .. num1.num.length)
	{
		if (num1.num[i] && num2.num[i])
			output.num ~= 1;
		else
			output.num ~= 0;
	}
	return convToDecimal!V(output);
}

unittest
{
	import std.random : uniform;
	writeln("and test");
	foreach (i; 0 .. 100)
	{
		auto num1 = uniform(0, 100);
		auto num2 = uniform(0, 100);
		assert(and(num1, num2) == (num1 & num2));
	}
	writeln("and done");
}

V xor(T, V = ulong)(T a, T b)
{
	BaseNumber output;
	BaseNumber num1;
	BaseNumber num2;
	static if (!is(a : BaseNumber))
	{
		num1 = convToBase(a);
		num2 = convToBase(b);
	}
	else
	{
		num1 = a;
		num2 = b;
	}
	while (num1.num.length != num2.num.length)
	{
		if (num1.num.length < num2.num.length)
			num1.num = num1.num.insert(0, 0);
		else
			num2.num = num2.num.insert(0, 0);
	}
	foreach_reverse (i; 0 .. num1.num.length)
	{
		if ((num1.num[i] && !num2.num[i]) ||
			(num2.num[i] && !num1.num[i]))
			output.num ~= 1;
		else
			output.num ~= 0;
	}
	return convToDecimal!V(output);
}

unittest
{
	import std.random : uniform;
	writeln("Xor test");
	foreach (i; 0 .. 100)
	{
		auto num1 = uniform(0, 100);
		auto num2 = uniform(0, 100);
		assert(xor(num1, num2) == (num1 ^ num2));
	}
	writeln("Xor done");
}

BaseNumber not(T)(T a)
{
	BaseNumber output;
	static if (!is(typeof(a) : BaseNumber))
		output = convToBase(a);
	else
		output = a;
	foreach (i; 0 .. output.num.length)
		output.num[i] = cast(int)!output.num[i];
	return output;
}

unittest
{
	import std.random : uniform;
	writeln("Not test");
	foreach (i; 0 .. 10)
	{
		uint num1 = uniform(1, 10);
		assert(convToDecimal!ulong(not(not(num1))) == num1);
	}
	writeln("Not done");
}

V shift(T, V = ulong)(T a, int times, char dir)
{
	BaseNumber output;
	V tmp;
	static if (!is(typeof(a) : BaseNumber))
		output = convToBase(a);
	else
		output = a;
	foreach (i; 0 .. times)
	{
		if (dir == 'l')
		{
			output.num ~= 0;
			output.bits++;
		}
		else if (dir == 'r')
		{
			if (output.num.length > 1)
				output.num.length--;
			else
			{
				output.num[0] = 0;
				break;
			}
			output.bits--;
		}
	}
	return convToDecimal!V(output);
}

V leftshift(T, V = ulong)(T a, int times)
{
	return shift!(T, V)(a, times, 'l');
}

V rightshift(T, V = ulong)(T a, int times)
{
	return shift!(T, V)(a, times, 'r');
}

//Add unitests for shift

T add(T)(T x, T y)
{
	T sum;
	T carry;

	sum = xor!(T, T)(x, y);
	carry = and!(T, T)(x, y);
	while (carry != 0)
	{
		carry = leftshift!(T, T)(carry, 1);
		x = sum;
		y = carry;
		sum = xor!(T, T)(x, y);
		carry = and!(T, T)(x, y);
	}
	return sum;
}

unittest
{
	import std.random : uniform;
	writeln("add test");
	foreach (i; 0 .. 100)
	{
		int a = uniform(1, 1000000);
		int b = uniform(1, 1000000);
		assert(add(a, b) == (a + b));
	}
	writeln("add done");
}
