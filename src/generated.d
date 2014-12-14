module generated;

import std.random;
import std.stdio;
import std.algorithm;
import std.range;

void main()
{
	generateModule(stdout);
}

immutable string IDENT_CHARS = chain(iota(cast (ubyte) 'a', cast (ubyte) 'z'),
	iota(cast (ubyte) 'A', cast (ubyte) 'Z'), only(cast (ubyte) '_')).array();

immutable string[] REGISTER_NAMES = [
	"AH", "AL", "AX", "BH", "BL", "BP", "BPL", "BX", "CH", "CL", "CR0", "CR2",
	"CR3", "CR4", "CS", "CX", "DH", "DI", "DIL", "DL", "DR0", "DR1", "DR2",
	"DR3", "DR6", "DR7", "DS", "DX", "EAX", "EBP", "EBX", "ECX", "EDI", "EDX",
	"ES", "ESI", "ESP", "FS", "GS", "MM0", "MM1", "MM2", "MM3", "MM4", "MM5",
	"MM6", "MM7", "R10", "R10B", "R10D", "R10W", "R11", "R11B", "R11D", "R11W",
	"R12", "R12B", "R12D", "R12W", "R13", "R13B", "R13D", "R13W", "R14", "R14B",
	"R14D", "R14W", "R15", "R15B", "R15D", "R15W", "R8", "R8B", "R8D", "R8W",
	"R9", "R9B", "R9D", "R9W", "RAX", "RBP", "RBX", "RCX", "RDI", "RDX", "RSI",
	"RSP", "SI", "SIL", "SP", "SPL", "SS", "ST", "TR3", "TR4", "TR5", "TR6",
	"TR7", "XMM0", "XMM1", "XMM10", "XMM11", "XMM12", "XMM13", "XMM14", "XMM15",
	"XMM2", "XMM3", "XMM4", "XMM5", "XMM6", "XMM7", "XMM8", "XMM9", "YMM0",
	"YMM1", "YMM10", "YMM11", "YMM12", "YMM13", "YMM14", "YMM15", "YMM2",
	"YMM3", "YMM4", "YMM5", "YMM6", "YMM7", "YMM8", "YMM9"
];

immutable string[] IDENTIFIERS = [
	"apple", "orange", "raspberry", "grape", "pineapple", "gosh", "omg",
	"ouchMyFinger", "aaargh", "plastic", "cocaine", "migrane", "knife",
	"acrylic", "phone", "remote", "tape", "drywall", "carton", "eggplant",
	"emerge", "items", "slash" , "freedom", "angelic", "boom", "nanny_ogg",
	"discworld", "monday", "zelda", "portal", "dumbass"
];

struct Choice
{
	int weight;
	void function(File f) action;
}

void arbitraryCall(File f, Choice[] choices ...)
{
	int[] weights = choices.map!(a => a.weight).array();
	choices[dice(weights)].action(f);
}

uint times(uint atLeast, uint atMost)
{
	return atLeast + cast(uint) iota(0, atMost - atLeast)
		.map!(a => (atMost - a) ^^ 2)
		.dice();
}

void generateInheritable(File f)
{
	generateIdentifier(f);
	arbitraryCall(f, [
		Choice(1, function (File f) {
			f.writeln(";");
		}),
		Choice(1, function (File f) {
			if (coinFlip())
			{
				f.write(" : ");
				generateBaseClassList(f);
			}
			f.writeln();
			generateStructBody(f);
		}),
		Choice(1, function (File f) {
			generateTemplateParameters(f);
			if (coinFlip())
			{
				f.write(" ");
				generateConstraint(f);
			}
			if (coinFlip())
			{
				f.write(" : ");
				generateBaseClassList(f);
			}
			f.writeln();
			generateStructBody(f);
		}),
		Choice(1, function (File f) {
			generateTemplateParameters(f);
			if (coinFlip())
			{
				f.write(" : ");
				generateBaseClassList(f);
			}
			if (coinFlip())
			{
				f.write(" ");
				generateConstraint(f);
			}
			f.writeln();
			generateStructBody(f);
		}),
	]);
}

uint generateSeparated(alias functionName)(uint atLeast, uint atMost, string separator, File f)
{
	uint n = times(atLeast, atMost);
	foreach (i; 0 .. n)
	{
		functionName(f);
		if (i + 1 < n)
			f.write(separator);
	}
	return n;
}

void generateTypeConstructor(File f)
{
	auto typeConstructors = ["const", "immutable", "inout", "shared"];
	f.write(randomSample(typeConstructors, 1).front);
}

bool coinFlip()
{
	return uniform(0, 2) == 1;
}

void generateIdentifier(File f)
{
	f.write(randomSample(IDENTIFIERS, 1).front);
}

void generateStringLiteral(File f)
{
	f.write("\"", IDENTIFIERS[uniform(0, IDENTIFIERS.length)], "\"");
}

void generateCharacterLiteral(File f)
{
	f.write("'");
	f.write(cast (char) randomSample(cast (ubyte[]) IDENT_CHARS, 1).front);
	f.write("'");
}

void generateFloatLiteral(File f)
{
	f.write(uniform(0.0, 100_000));
}

void generateIntLiteral(File f)
{
	f.write(uniform(0, 100_000));
}

void generateBinaryExpression(alias thisGenerator, alias partGenerator, string[] operators)(File f)
{
	if (dice(100, 2))
	{
		thisGenerator(f);
		f.write(" ");
		f.write(operators[uniform(0, operators.length)]);
		f.write(" ");
	}
	partGenerator(f);
}

void generateAddExpression(File f)
{
	generateBinaryExpression!(generateAddExpression, generateMulExpression, ["+"])(f);
}

void generateAliasDeclaration(File f)
{
	f.write("alias ");
	if (coinFlip())
		generateSeparated!(generateAliasInitializer)(1, 3, ", ", f);
	else
	{
		if (generateSeparated!(generateStorageClass)(0, 4, " ", f))
			f.write(" ");
		generateType(f);
		f.write(" ");
		generateIdentifierList(f);
	}
	f.writeln(";");
}

void generateAliasInitializer(File f)
{
	generateIdentifier(f);
	if (coinFlip())
		generateTemplateParameters(f);
	f.write(" = ");
	if (generateSeparated!(generateStorageClass)(0, 4, " ", f) > 0)
		f.write(" ");
	generateType(f);
}

void generateAliasThisDeclaration(File f)
{
	f.write("alias ");
	generateIdentifier(f);
	f.writeln(" this;");
}

void generateAlignAttribute(File f)
{
	f.write("align");
	if (coinFlip())
	{
		f.write("(");
		generateIntLiteral(f);
		f.write(")");
	}
}

void generateAndAndExpression(File f)
{
	generateBinaryExpression!(generateAndAndExpression, generateOrExpression, ["&&"])(f);
}

void generateAndExpression(File f)
{
	generateBinaryExpression!(generateAndExpression, generateCmpExpression, ["&"])(f);
}

void generateArgumentList(File f)
{
	generateSeparated!(generateAssignExpression)(1, 10, ", ", f);
}

void generateArguments(File f)
{
	f.write("(");
	generateArgumentList(f);
	f.write(")");
}

void generateArrayInitializer(File f)
{
	f.write("[");
	generateSeparated!(generateArrayMemberInitialization)(0, 30, ", ", f);
	f.write("]");
}

void generateArrayLiteral(File f)
{
	f.write("[");
	if (coinFlip())
		generateArgumentList(f);
	f.write("]");
}

void generateArrayMemberInitialization(File f)
{
	if (coinFlip())
	{
		generateAssignExpression(f);
		f.write(" : ");
	}
	generateNonVoidInitializer(f);
}

void generateAsmAddExp(File f)
{
	generateBinaryExpression!(generateAsmAddExp, generateAsmMulExp, ["+", "-"])(f);
}

void generateAsmAndExp(File f)
{
	generateBinaryExpression!(generateAsmAndExp, generateAsmEqualExp, ["&"])(f);
}

void generateAsmBrExp(File f)
{
	if (dice(10, 90))
		generateAsmUnaExp(f);
	else
	{
		if (coinFlip())
			generateAsmBrExp(f);
		f.write("[");
		generateAsmExp(f);
		f.write("]");
	}
}

void generateAsmEqualExp(File f)
{
	generateBinaryExpression!(generateAsmEqualExp, generateAsmRelExp, ["==", "!="])(f);
}

void generateAsmExp(File f)
{
	generateAsmLogOrExp(f);
	if (dice(9, 1))
	{
		f.write(" ? ");
		generateAsmExp(f);
		f.write(" : ");
		generateAsmExp(f);
	}
}

void generateAsmInstruction(File f)
{
	switch (dice(2, 1, 1, 1, 6, 1, 1, 1))
	{
	case 0:
		generateIdentifier(f);
		break;
	case 1:
		f.write("align ");
		generateIntLiteral(f);
		break;
	case 2:
		f.write("align ");
		generateIdentifier(f);
		break;
	case 3:
		generateIdentifier(f);
		f.write(" : ");
		generateAsmInstruction(f);
		break;
	case 4:
		generateIdentifier(f);
		f.write(" ");
		generateOperands(f);
		break;
	case 5:
		f.write("in ");
		generateOperands(f);
		break;
	case 6:
		f.write("out ");
		generateOperands(f);
		break;
	case 7:
		f.write("int ");
		generateOperands(f);
		break;
	default:
		assert (false, __FUNCTION__);
	}
}

void generateAsmLogAndExp(File f)
{
	generateBinaryExpression!(generateAsmLogAndExp, generateAsmOrExp, ["&&"])(f);
}

void generateAsmLogOrExp(File f)
{
	generateBinaryExpression!(generateAsmLogOrExp, generateAsmLogAndExp, ["||"])(f);
}

void generateAsmMulExp(File f)
{
	generateBinaryExpression!(generateAsmMulExp, generateAsmBrExp, ["*", "/", "%"])(f);
}

void generateAsmOrExp(File f)
{
	generateBinaryExpression!(generateAsmOrExp, generateAsmXorExp, ["|"])(f);
}

void generateAsmPrimaryExp(File f)
{
	arbitraryCall(f, [
		Choice(10, &generateIntLiteral),
		Choice(10, &generateFloatLiteral),
		Choice(10, &generateIdentifierChain),
		Choice(1 , function (File f) {
			f.write("$");
		}),
		Choice(1 , function (File f) {
			generateRegister(f);
			if (dice(3, 1))
			{
				f.write(" : ");
				generateAsmExp(f);
			}
		})
	]);
}

void generateAsmRelExp(File f)
{
	generateBinaryExpression!(generateAsmRelExp, generateAsmShiftExp, ["<", "<=", ">", ">="])(f);
}

void generateAsmShiftExp(File f)
{
	generateBinaryExpression!(generateAsmShiftExp, generateAsmAddExp, ["<", ">>", ">>>"])(f);
}

void generateAsmStatement(File f)
{
	f.write("asm");
	if (coinFlip())
	{
		f.write(" ");
		generateSeparated!(generateFunctionAttribute)(0, 4, " ", f);
	}
	f.writeln();
	f.writeln("{");
	foreach (_; 0 .. times(0, 8))
	{
		generateAsmInstruction(f);
		f.writeln(";");
	}
	f.writeln("}");
}

void generateAsmTypePrefix(File f)
{
	f.write(["near", "far", "word", "dword", "qword", "byte", "short", "int",
		"float", "double", "real"].randomSample(1).front);
	if (coinFlip())
		f.write(" ptr");
}

void generateAsmUnaExp(File f)
{
	switch (dice(1, 1, 1, 6))
	{
	case 0:
		generateAsmTypePrefix(f);
		f.write(" ");
		generateAsmExp(f);
		break;
	case 1:
		generateIdentifier(f);
		f.write(" ");
		generateAsmExp(f);
		break;
	case 2:
		f.write(["+", "-", "!", "~"].randomSample(1).front);
		generateAsmUnaExp(f);
		break;
	case 3:
		generateAsmPrimaryExp(f);
		break;
	default:
		assert (false, __FUNCTION__);
	}
}

void generateAsmXorExp(File f)
{
	generateBinaryExpression!(generateAsmXorExp, generateAsmAndExp, ["^"])(f);
}

void generateAssertExpression(File f)
{
	f.write("assert (");
	generateAssignExpression(f);
	if (coinFlip())
	{
		f.write(", ");
		generateAssignExpression(f);
	}
	f.write(")");
}

void generateAssignExpression(File f)
{
	generateTernaryExpression(f);
	if (dice(95, 5))
	{
		f.write(" ");
		f.write(["=", ">>>=", ">>=", "<<=", "+=", "-=", "*=", "%=", "&=", "/=",
			"|=", "^^=", "^=", "~="].randomSample(1).front);
		f.write(" ");
		generateAssignExpression(f);
	}
}

void generateAssocArrayLiteral(File f)
{
	f.write("[");
	generateKeyValuePairs(f);
	f.write("]");
}

void generateAtAttribute(File f)
{
	f.write("@");
	arbitraryCall(f, [
		Choice(10, function (File f) {
			f.write("(");
			generateArgumentList(f);
			f.write(")");
		}),
		Choice(1, function (File f) {
			generateIdentifier(f);
			f.write("(");
			if (coinFlip())
				generateArgumentList(f);
			f.write(")");
		}),
		Choice(20, &generateIdentifier)
	]);
}

void generateAttribute(File f)
{
	switch (uniform(0, 7))
	{
	case 0:
		generatePragmaExpression(f);
		break;
	case 1:
		generateStorageClass(f);
		break;
	case 2:
		f.write("export");
		break;
	case 3:
		f.write("package");
		break;
	case 4:
		f.write("private");
		break;
	case 5:
		f.write("protected");
		break;
	case 6:
		f.write("public");
		break;
	default:
		assert (false, __FUNCTION__);
	}
}
void generateAttributeDeclaration(File f)
{
	generateAttribute(f);
	f.writeln(":");
}

void generateAutoDeclaration(File f)
{
	generateStorageClass(f);
	f.write(" ");
	auto n = uniform(1, 3);
	foreach (i; 0 .. n)
	{
		generateIdentifier(f);
		f.write(" = ");
		generateInitializer(f);
		if (i + 1 < n)
			f.write(", ");
	}
	f.writeln(";");
}

void generateBlockStatement(File f)
{
	f.writeln("{");
	if (coinFlip())
		generateDeclarationsAndStatements(f);
	f.writeln("}");
}
void generateBodyStatement(File f)
{
	f.writeln("body");
	generateBlockStatement(f);
}

void generateBreakStatement(File f)
{
	f.write("break");
	if (coinFlip())
	{
		f.write(" ");
		generateIdentifier(f);
	}
	f.write(";");
}

void generateBaseClass(File f)
{
	generateType2(f);
}

void generateBaseClassList(File f)
{
	generateSeparated!(generateBaseClass)(1, 2, ", ", f);
}

void generateBuiltinType(File f)
{
	auto builtinTypes = ["int", "uint", "double", "idouble", "float", "ifloat",
		"short", "ushort", "long", "ulong", "char", "wchar", "dchar", "bool",
		"void", "cent", "ucent", "real", "ireal", "byte", "ubyte", "cdouble",
		"cfloat", "creal"];
	f.write(randomSample(builtinTypes, 1).front);
}

void generateCaseRangeStatement(File f)
{
	f.write("case ");
	generateAssignExpression(f);
	f.write(": .. case ");
	generateAssignExpression(f);
	f.writeln(":");
	generateDeclarationsAndStatements(f);
}

void generateCaseStatement(File f)
{
	f.write("case ");
	generateAssignExpression(f);
	f.writeln(":");
	generateDeclarationsAndStatements(f);
}

void generateCastExpression(File f)
{
	f.write("cast (");
	switch (uniform(0, 3))
	{
	case 0: generateType(f); break;
	case 1: generateCastQualifier(f); break;
	case 2: break;
	default: assert (false, __FUNCTION__);
	}
	f.write(") ");
	generateUnaryExpression(f);
}

void generateCastQualifier(File f)
{
	switch (uniform(0, 4))
	{
	case 0:
		f.write("const");
		if (coinFlip())
			f.write(" shared");
		break;
	case 1: f.write("immutable"); break;
	case 2:
		f.write("inout");
		if (coinFlip())
			f.write(" shared");
		break;
	case 3:
		f.write("shared");
		switch (uniform(0, 3))
		{
		case 0: break;
		case 1: f.write(" const"); break;
		case 2: f.write(" inout"); break;
		default: assert (false, __FUNCTION__);
		}
		break;
	default: assert (false, __FUNCTION__);
	}
}

void generateCatch(File f)
{
	f.write("catch (");
	generateType(f);
	if (coinFlip)
	{
		f.write(" ");
		generateIdentifier(f);
	}
	f.writeln(")");
	generateDeclarationOrStatement(f);
}

void generateCatches(File f)
{
	foreach (_; 0 .. uniform(0, 4))
		generateCatch(f);
	generateLastCatch(f);
}

void generateClassDeclaration(File f)
{
	f.write("class ");
	generateInheritable(f);
}

void generateCmpExpression(File f)
{
	switch (dice(10, 1, 1, 1, 1))
	{
	case 0: generateShiftExpression(f); break;
	case 1: generateEqualExpression(f); break;
	case 2: generateIdentityExpression(f); break;
	case 3: generateRelExpression(f); break;
	case 4: generateInExpression(f); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateCompileCondition(File f)
{
	arbitraryCall(f, [
		Choice(1, &generateVersionCondition),
		Choice(1, &generateDebugCondition),
		Choice(1, &generateStaticIfCondition)
	]);
}

void generateConditionalDeclaration(File f)
{
	generateCompileCondition(f);
	arbitraryCall(f, [
		Choice(1, function (File f) {
			 f.writeln(); generateDeclaration(f);
		}),
		Choice(1, function (File f) {
			f.writeln(":");
			foreach (_; 0 .. times(1, 5))
				generateDeclaration(f);
		}),
		Choice(1, function (File f) {
			f.writeln();
			generateDeclaration(f);
			f.writeln("else");
			generateDeclaration(f);
		})
	]);
}

void generateConditionalStatement(File f)
{
	generateCompileCondition(f);
	f.writeln();
	generateDeclarationOrStatement(f);
	if (coinFlip())
	{
		f.writeln("else");
		generateDeclarationOrStatement(f);
	}
}

void generateConstraint(File f)
{
	f.write("if (");
	generateExpression(f);
	f.write(")");
}

void generateConstructor(File f)
{
	f.write("this");
	if (coinFlip())
	{
		generateTemplateParameters(f);
		generateParameters(f);
		if (generateSeparated!(generateMemberFunctionAttribute)(0, 3, " ", f))
			f.write(" ");
		if (coinFlip())
			generateConstraint(f);
	}
	else
	{
		generateParameters(f);
		if (generateSeparated!(generateMemberFunctionAttribute)(0, 3, " ", f))
			f.write(" ");
	}
	if (coinFlip())
	{
		f.writeln();
		generateFunctionBody(f);
	}
	else
		f.writeln(";");
}

void generateContinueStatement(File f)
{
	f.write("continue");
	if (coinFlip)
	{
		f.write(" ");
		generateIdentifier(f);
	}
	f.writeln(";");
}

void generateDebugCondition(File f)
{
	f.write("debug");
	if (coinFlip())
	{
		f.write(" (");
		if (coinFlip())
			generateIdentifier(f);
		else
			generateIntLiteral(f);
		f.write(")");
	}
}

void generateDebugSpecification(File f)
{
	f.write("debug = ");
	if (coinFlip())
		generateIdentifier(f);
	else
		generateIntLiteral(f);
	f.writeln(";");
}

void generateDeclaration(File f)
{
	if (dice(5, 1))
	{
		generateSeparated!(generateAttribute)(1, 4, " ", f);
		f.write(" ");
	}
	arbitraryCall(f, [
		Choice(1, &generateAliasDeclaration),
		Choice(1, &generateAliasThisDeclaration),
		Choice(1, &generateAttributeDeclaration),
		Choice(1, &generateConditionalDeclaration),
		Choice(1, &generateConstructor),
		Choice(1, &generateDebugSpecification),
		Choice(1, &generateDestructor),
		Choice(1, &generateEponymousTemplateDeclaration),
		Choice(4, &generateFunctionDeclaration),
		Choice(1, &generateInvariant),
		Choice(1, &generateMixinDeclaration),
		Choice(1, &generateMixinTemplateDeclaration),
		Choice(1, &generatePragmaDeclaration),
		Choice(1, &generateSharedStaticConstructor),
		Choice(1, &generateSharedStaticDestructor),
		Choice(1, &generateStaticAssertDeclaration),
		Choice(1, &generateStaticConstructor),
		Choice(1, &generateStaticDestructor),
		Choice(1, &generateTemplateDeclaration),
		Choice(1, &generateUnionDeclaration),
		Choice(1, &generateVersionSpecification),
		Choice(2, &generateImportDeclaration),
		Choice(4, &generateClassDeclaration),
		Choice(4, &generateEnumDeclaration),
		Choice(4, &generateInterfaceDeclaration),
		Choice(4, &generateStructDeclaration),
		Choice(4, &generateUnittest),
		Choice(4, &generateVariableDeclaration)
	]);
}

void generateDeclarationOrStatement(File f)
{
	if (coinFlip)
		generateDeclaration(f);
	else
		generateStatement(f);
}

void generateDeclarationsAndStatements(File f)
{
	foreach (i; 0 .. dice(1, 16, 8, 2, 1))
		generateDeclarationOrStatement(f);
}

void generateDeclarator(File f)
{
	generateIdentifier(f);
	switch (uniform(0, 3))
	{
	case 0: break;
	case 1: f.write(" = "); generateInitializer(f); break;
	case 2: generateTemplateParameters(f); f.write(" = "); generateInitializer(f); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateDefaultStatement(File f)
{
	f.writeln("default:");
	generateDeclarationsAndStatements(f);
}

void generateDeleteExpression(File f)
{
	f.write("delete ");
	generateUnaryExpression(f);
}

void generateDeleteStatement(File f)
{
	generateDeleteExpression(f);
	f.writeln(";");
}

void generateDeprecated(File f)
{
	f.write("deprecated");
	if (coinFlip())
	{
		f.write(" (");
		generateStringLiteral(f);
		f.write(")");
	}
}

void generateDestructor(File f)
{
	f.write("~this() ");
	generateSeparated!(generateMemberFunctionAttribute)(0, 3, " ", f);
	if (coinFlip())
	{
		f.writeln();
		generateFunctionBody(f);
	}
	else
		f.writeln(";");
}

void generateDoStatement(File f)
{
	f.writeln("do");
	generateStatementNoCaseNoDefault(f);
	f.write("while (");
	generateExpression(f);
	f.write(");");
}

void generateEnumBody(File f)
{
	if (coinFlip())
		f.writeln(";");
	else
	{
		f.writeln();
		f.writeln("{");
		generateSeparated!(generateEnumMember)(1, 10, ", ", f);
		f.writeln();
		f.writeln("}");
	}
}

void generateEnumDeclaration(File f)
{
	f.write("enum");
	if (coinFlip())
	{
		f.write(" ");
		generateIdentifier(f);
	}
	if (coinFlip())
	{
		f.write(" : ");
		generateType(f);
	}
	generateEnumBody(f);
}

void generateEnumMember(File f)
{
	if (coinFlip())
	{
		generateIdentifier(f);
		f.write(" ");
	}
	else
	{
		if (coinFlip())
			generateType(f);
		generateIdentifier(f);
		f.write(" = ");
		generateAssignExpression(f);
	}
}

void generateEponymousTemplateDeclaration(File f)
{
	if (coinFlip())
		f.write("enum ");
	else
		f.write("alias ");
	generateIdentifier(f);
	f.write(" ");
	generateTemplateParameters(f);
	f.write(" = ");
	if (coinFlip())
		generateAssignExpression(f);
	else
		generateType(f);
	f.writeln(";");
}

void generateEqualExpression(File f)
{
	generateShiftExpression(f);
	if (coinFlip)
		f.write(" == ");
	else
		f.write(" != ");
	generateShiftExpression(f);
}

void generateExpression(File f)
{
	while (true)
	{
		generateAssignExpression(f);
		if (dice(95, 5))
			f.write(", ");
		else
			break;
	}
}

void generateExpressionStatement(File f)
{
	generateExpression(f);
	f.writeln(";");
}

void generateFinalSwitchStatement(File f)
{
	f.write("final ");
	generateSwitchStatement(f);
}

void generateFinally(File f)
{
	f.writeln("finally");
	generateDeclarationOrStatement(f);
}

void generateForStatement(File f)
{
	f.write("for (");
	generateDeclarationOrStatement(f);
	if (coinFlip())
	{
		f.write(" ");
		generateExpression(f);
	}
	f.write("; ");
	if (coinFlip())
		generateExpression(f);
	f.writeln(")");
	if (dice(10, 90))
		generateDeclarationOrStatement(f);
	else
		generateBlockStatement(f);
}

void generateForeachStatement(File f)
{
	if (coinFlip())
		f.write("foreach (");
	else
		f.write("foreach_reverse (");
	if (coinFlip())
	{
		generateForeachType(f);
		f.write("; ");
		generateExpression(f);
		f.write(" .. ");
		generateExpression(f);
	}
	else
	{
		generateForeachTypeList(f);
		f.write("; ");
		generateExpression(f);
	}
	f.writeln(")");
	if (dice(10, 90))
		generateDeclarationOrStatement(f);
	else
		generateBlockStatement(f);
}

void generateForeachType(File f)
{
	if (coinFlip())
	{
		generateTypeConstructor(f);
		f.write(" ");
	}
	if (coinFlip())
	{
		generateType(f);
		f.write(" ");
	}
	generateIdentifier(f);
}

void generateForeachTypeList(File f)
{
	generateSeparated!(generateForeachType)(1, 3, ", ", f);
}

void generateFunctionAttribute(File f)
{
	switch (uniform(0, 3))
	{
	case 0: generateAtAttribute(f); break;
	case 1: f.write("nothrow"); break;
	case 2: f.write("pure"); break;
	default: assert(false, __FUNCTION__);
	}
}

void generateFunctionBody(File f)
{
	if (dice(1, 4))
		generateBlockStatement(f);
	else
	{
		if (coinFlip())
		{
			generateInStatement(f);
			generateOutStatement(f);
		}
		else
		{
			generateOutStatement(f);
			generateInStatement(f);
		}
		generateBodyStatement(f);
	}
}

void generateFunctionCallExpression(File f)
{
	if (coinFlip())
	{
		generateUnaryExpression(f);
		if (coinFlip())
			generateTemplateArguments(f);
	}
	else
		generateType(f);
	generateArguments(f);
}

void generateFunctionDeclaration(File f)
{
	if (coinFlip())
		generateType(f);
	else
		generateStorageClass(f);
	f.write(" ");
	generateIdentifier(f);
	if (coinFlip())
	{
		generateTemplateParameters(f);
		generateParameters(f);
		generateSeparated!(generateMemberFunctionAttribute)(0, 2, " ", f);
		if (coinFlip())
		{
			generateConstraint(f);
			f.write(" ");
		}
	}
	else
	{
		generateParameters(f);
		generateSeparated!(generateMemberFunctionAttribute)(0, 2, " ", f);
	}
	if (coinFlip())
	{
		 f.writeln();
		 generateFunctionBody(f);
	}
	else
		f.writeln(";");
}

void generateFunctionLiteralExpression(File f)
{
	if (coinFlip())
	{
		if (coinFlip())
			f.write("function ");
		else
			f.write("delegate ");
		if (coinFlip())
		{
			generateType(f);
			f.write(" ");
		}
	}
	if (coinFlip())
	{
		generateParameters(f);
		generateSeparated!(generateFunctionAttribute)(0, 3, " ", f);
	}
	f.writeln();
	generateFunctionBody(f);
}

void generateGotoStatement(File f)
{
	f.write("goto");
	arbitraryCall(f, [
		Choice(10, function (File f) {
			f.write(" ");
			generateIdentifier(f);
		}),
		Choice(10, function (File f) {
			f.write(" default");
		}),
		Choice(1, function (File f) {
			f.write(" case");
			if (coinFlip())
				generateExpression(f);
		})
	]);
	f.writeln(";");
}

void generateIdentifierChain(File f)
{
	generateSeparated!(generateIdentifier)(1, 6, ".", f);
}

void generateIdentifierList(File f)
{
	generateSeparated!(generateIdentifier)(1, 6, ", ", f);
}

void generateIdentifierOrTemplateChain(File f)
{
	generateSeparated!(generateIdentifierOrTemplateInstance)(1, 6, ".", f);
}

void generateIdentifierOrTemplateInstance(File f)
{
	arbitraryCall(f, [
		Choice(8, &generateIdentifier),
		Choice(2, &generateTemplateInstance)
	]);
}

void generateIdentityExpression(File f)
{
	generateShiftExpression(f);
	f.write(" ");
	if (coinFlip())
		f.write("!");
	f.write("is ");
	generateShiftExpression(f);
}

void generateIfStatement(File f)
{
	f.write("if (");
	arbitraryCall(f, [
		Choice(1, function (File f) {
			f.write("auto ");
			generateIdentifier(f);
			f.write(" = ");
			generateExpression(f);
		}),
		Choice(1, function (File f) {
			generateType(f);
			f.write(" ");
			generateIdentifier(f);
			f.write(" = ");
			generateExpression(f);
		}),
		Choice(2, &generateExpression)
	]);
	f.writeln(")");
	generateDeclarationOrStatement(f);
}

void generateImportBind(File f)
{
	generateIdentifier(f);
	if (coinFlip())
	{
		f.write(" = ");
		generateIdentifier(f);
	}
}

void generateImportBindings(File f)
{
	generateSingleImport(f);
	f.write(" : ");
	generateSeparated!(generateImportBind)(1, 3, ", ", f);
}

void generateImportDeclaration(File f)
{
	f.write("import ");
	if (coinFlip())
	{
		generateSeparated!(generateSingleImport)(1, 3, ", ", f);
		if (coinFlip())
		{
			f.write(", ");
			generateImportBindings(f);
		}
	}
	else
		generateImportBindings(f);
	f.writeln(";");
}

void generateImportExpression(File f)
{
	f.write("import (");
	generateAssertExpression(f);
	f.write(")");
}

void generateIndexExpression(File f)
{
	generateUnaryExpression(f);
	f.write("[");
	generateArgumentList(f);
	f.write("]");
}

void generateInExpression(File f)
{
	generateShiftExpression(f);
	f.write(" ");
	if (coinFlip())
		f.write("!");
	f.write("in ");
	generateShiftExpression(f);

}

void generateInStatement(File f)
{
	f.writeln("in");
	generateBlockStatement(f);
}

void generateInitializer(File f)
{
	if (coinFlip())
		f.write("void");
	else
		generateNonVoidInitializer(f);
}

void generateInterfaceDeclaration(File f)
{
	f.write("interface ");
	generateInheritable(f);
}

void generateInvariant(File f)
{
	f.write("invariant");
	if (coinFlip())
	{
		f.writeln(" ()");
	}
	else
		f.writeln();
	generateBlockStatement(f);
}

void generateIsExpression(File f)
{
	f.write("is (");
	generateType(f);
	if (coinFlip())
		generateIdentifier(f);
	arbitraryCall(f, [
		Choice(1, function (File f) {
			f.write(" : ");
			generateTypeSpecialization(f);
		}),
		Choice(1, function (File f) {
			f.write(" = ");
			generateTypeSpecialization(f);
		}),
		Choice(1, function (File f) {
			f.write(" : ");
			generateTypeSpecialization(f);
			f.write(", ");
			generateTemplateParameterList(f);
		}),
		Choice(1, function (File f) {
			f.write(" = ");
			generateTypeSpecialization(f);
			f.write(", ");
			generateTemplateParameterList(f);
		}),
		Choice(10, function (File f) {})
	]);
	f.write(")");
}

void generateKeyValuePair(File f)
{
	generateAssignExpression(f);
	f.write(" : ");
	generateAssignExpression(f);
}

void generateKeyValuePairs(File f)
{
	generateSeparated!(generateKeyValuePair)(1, 10, ", ", f);
	if (coinFlip())
		f.write(",");
}

void generateLabeledStatement(File f)
{
	generateIdentifier(f);
	f.writeln(":");
	generateDeclarationOrStatement(f);
}

void generateLambdaExpression(File f)
{
	arbitraryCall(f, [
		Choice(5, &generateIdentifier),
		Choice(1, function (File f) {
			if (coinFlip())
				f.write("function ");
			else
				f.write("delegate ");
			if (coinFlip())
				generateType(f);
			generateParameters(f);
			generateSeparated!(generateFunctionAttribute)(0, 2, " ", f);
		}),
		Choice(1, function (File f) {
			generateParameters(f);
			generateSeparated!(generateFunctionAttribute)(0, 2, " ", f);
		})
	]);
	f.write(" => ");
	generateAssignExpression(f);
}

void generateLastCatch(File f)
{
	f.writeln("catch");
	generateStatementNoCaseNoDefault(f);
}

void generateLinkageAttribute(File f)
{
	f.write("extern (");
	switch (uniform(0, 6))
	{
	case 0: f.write("C"); break;
	case 1:
		f.write("C++");
		if (coinFlip())
		{
			f.write(", ");
			generateIdentifierChain(f);
		}
		break;
	case 2: f.write("D"); break;
	case 3: f.write("Windows"); break;
	case 4: f.write("Pascal"); break;
	case 5: f.write("System"); break;
	default: assert (false, __FUNCTION__);
	}
	f.write(")");
}

void generateMemberFunctionAttribute(File f)
{
	switch (uniform(0, 5))
	{
	case 0: generateFunctionAttribute(f); break;
	case 1: f.write("immutable"); break;
	case 2: f.write("inout"); break;
	case 3: f.write("shared"); break;
	case 4: f.write("const"); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateMixinDeclaration(File f)
{
	arbitraryCall(f, [
		Choice(1, &generateMixinExpression),
		Choice(1, &generateTemplateMixinExpression)
	]);
	f.writeln(";");
}

void generateMixinExpression(File f)
{
	f.write("mixin (");
	generateAssignExpression(f);
	f.write(")");
}

void generateMixinTemplateDeclaration(File f)
{
	f.write("mixin ");
	generateTemplateDeclaration(f);
}

void generateMixinTemplateName(File f)
{
	if (coinFlip())
		generateSymbol(f);
	else
	{
		generateTypeofExpression(f);
		f.write(".");
		generateIdentifierOrTemplateChain(f);
	}
}

void generateModule(File f)
{
	if (dice(3, 1))
	{
		generateModuleDeclaration(f);
		f.write(" ");
	}
	foreach (_; 0 .. uniform(1, 5))
		generateDeclaration(f);
}

void generateModuleDeclaration(File f)
{
	if (coinFlip())
	{
		generateDeprecated(f);
		f.write(" ");
	}
	f.write("module ");
	generateIdentifierChain(f);
	f.writeln(";");
}

void generateMulExpression(File f)
{
	generateBinaryExpression!(generateMulExpression, generatePowExpression, ["*", "/", "%"])(f);
}

void generateNewAnonClassExpression(File f)
{
	f.write("new ");
	if (coinFlip())
	{
		generateArguments(f);
		f.write(" ");
	}
	f.write("class ");
	if (coinFlip())
	{
		generateArguments(f);
		f.write(" ");
	}
	if (coinFlip())
	{
		f.write(": ");
		generateBaseClassList(f);
		f.write(" ");
	}
	generateStructBody(f);
}

void generateNewExpression(File f)
{
	if (coinFlip())
		generateNewAnonClassExpression(f);
	else
	{
		f.write("new ");
		generateType(f);
		if (coinFlip())
		{
			f.write("[");
			generateAssignExpression(f);
			f.write("]");
		}
		else
			generateArguments(f);
	}
}

void generateNonVoidInitializer(File f)
{
	arbitraryCall(f, [
		Choice(10, &generateAssignExpression),
		Choice(1, &generateArrayInitializer),
		Choice(1, &generateStructInitializer),
		Choice(1, &generateFunctionBody)
	]);
}

void generateOperands(File f)
{
	generateSeparated!(generateAsmExp)(1, 2, ", ", f);
}

void generateOrExpression(File f)
{
	generateBinaryExpression!(generateOrExpression, generateXorExpression, ["|"])(f);
}

void generateOrOrExpression(File f)
{
	generateBinaryExpression!(generateOrOrExpression, generateAndAndExpression, ["||"])(f);
}

void generateOutStatement(File f)
{
	f.write("out");
	if (coinFlip())
	{
		f.write(" (");
		generateIdentifier(f);
		f.write(")");
	}
	f.writeln();
	generateBlockStatement(f);
}

void generateParameter(File f)
{
	if (generateSeparated!(generateParameterAttribute)(0, 2, " ", f))
		f.write(" ");
	generateType(f);
	f.write(" ");
	if (dice(20, 80))
		generateIdentifier(f);
	if (coinFlip())
		f.write("...");
	else if (coinFlip())
	{
		f.write(" = ");
		generateAssignExpression(f);
	}
}

void generateParameterAttribute(File f)
{
	f.write(["immutable", "shared", "const", "inout", "final", "in", "lazy",
		"out", "ref", "scope", "auto"].randomSample(1).front);
}

void generateParameters(File f)
{
	f.write("(");
	auto n = generateSeparated!(generateParameter)(0, 6, ", ", f);
	if (coinFlip())
	{
		if (n > 0)
			f.write(", ");
		f.write("...");
	}
	f.write(")");
}

void generatePostblit(File f)
{
	f.write("this(this) ");
	generateSeparated!(generateMemberFunctionAttribute)(0, 3, " ", f);
	if (coinFlip)
		f.writeln(";");
	else
	{
		f.writeln();
		generateFunctionBody(f);
	}
}

void generatePowExpression(File f)
{
	generateBinaryExpression!(generatePowExpression, generateUnaryExpression, ["^^"])(f);
}

void generatePragmaDeclaration(File f)
{
	generatePragmaExpression(f);
	f.writeln(";");
}

void generatePragmaExpression(File f)
{
	f.write("pragma (");
	f.write(["msg", "lib"].randomSample(1).front);
	if (coinFlip())
	{
		f.write(", ");
		generateArgumentList(f);
	}
	f.write(")");
}

void generatePrimaryExpression(File f)
{
	arbitraryCall(f, [
		Choice(1, &generateIdentifierOrTemplateInstance),
		Choice(1, function (File f) {
			f.write(".");
			generateIdentifierOrTemplateInstance(f);
		}),
		Choice(1, &generateTypeofExpression),
		Choice(1, &generateTypeidExpression),
		Choice(1, &generateVector),
		Choice(1, &generateArrayLiteral),
		Choice(1, &generateAssocArrayLiteral),
		Choice(20, &generateIdentifier),
		Choice(20, &generateIntLiteral),
		Choice(20, &generateFloatLiteral),
		Choice(20, &generateStringLiteral),
		Choice(20, &generateCharacterLiteral),
		Choice(1, &generateIsExpression),
		Choice(1, &generateLambdaExpression),
		Choice(1, &generateFunctionLiteralExpression),
		Choice(1, &generateTraitsExpression),
		Choice(1, &generateMixinExpression),
		Choice(1, &generateImportExpression),
		Choice(1, function (File f) {
			generateTypeConstructor(f);
			f.write("(");
			generateType(f);
			f.write(").");
			generateIdentifier(f);
		}),
		Choice(1, function (File f) {
			generateBuiltinType(f);
			f.write(".");
			generateIdentifier(f);
		}),
		Choice(1, function (File f) {
			generateBuiltinType(f);
			generateArguments(f);
		}),
		Choice(1, function (File f) {
			f.write("(");
			generateExpression(f);
			f.write(")");
		}),
		Choice(10, function (File f) {
			f.write(["$", "this", "super", "null", "true", "false", "__DATE__",
				"__TIME__", "__TIMESTAMP__", "__VENDOR__", "__VERSION__",
				"__FILE__", "__LINE__", "__MODULE__", "__FUNCTION__",
				"__PRETTY_FUNCTION__"].randomSample(1).front);
		}),
	]);
}

void generateRegister(File f)
{
	f.write(REGISTER_NAMES.randomSample(1).front);
	if (coinFlip())
	{
		f.write("(");
		generateIntLiteral(f);
		f.write(")");
	}
}

void generateRelExpression(File f)
{
	generateBinaryExpression!(generateRelExpression, generateShiftExpression,
		["<", "<=", ">", ">="])(f);
}

void generateReturnStatement(File f)
{
	f.write("return");
	if (coinFlip())
	{
		f.write(" ");
		generateExpression(f);
	}
	f.writeln(";");
}

void generateScopeGuardStatement(File f)
{
	f.write("scope (");
	f.write(["success", "failure", "exit"].randomSample(1).front);
	f.writeln(")");
	generateStatementNoCaseNoDefault(f);
}

void generateSharedStaticConstructor(File f)
{
	f.writeln("shared static this()");
	generateFunctionBody(f);
}

void generateSharedStaticDestructor(File f)
{
	f.writeln("shared static ~this()");
	generateFunctionBody(f);
}

void generateShiftExpression(File f)
{
	generateBinaryExpression!(generateShiftExpression, generateAddExpression,
		["<<", ">>", ">>>"])(f);
}

void generateSingleImport(File f)
{
	if (coinFlip())
	{
		generateIdentifier(f);
		f.write(" = ");
	}
	generateIdentifierChain(f);
}

void generateSliceExpression(File f)
{
	generateUnaryExpression(f);
	f.write("[");
	if (coinFlip())
	{
		generateAssignExpression(f);
		f.write(" .. ");
		generateAssignExpression(f);
	}
	f.write("]");
}

void generateStatement(File f)
{
	arbitraryCall(f, [
		Choice(10, &generateStatementNoCaseNoDefault),
		Choice(1, &generateCaseStatement),
		Choice(1, &generateCaseRangeStatement),
		Choice(1, &generateDefaultStatement)
	]);
	f.writeln();
}

void generateStatementNoCaseNoDefault(File f)
{
	arbitraryCall(f, [
		Choice(1, &generateLabeledStatement),
		Choice(1, &generateBlockStatement),
		Choice(1, &generateIfStatement),
		Choice(1, &generateWhileStatement),
		Choice(1, &generateDoStatement),
		Choice(1, &generateForStatement),
		Choice(1, &generateForeachStatement),
		Choice(1, &generateSwitchStatement),
		Choice(1, &generateFinalSwitchStatement),
		Choice(1, &generateContinueStatement),
		Choice(1, &generateBreakStatement),
		Choice(1, &generateReturnStatement),
		Choice(1, &generateGotoStatement),
		Choice(1, &generateWithStatement),
		Choice(1, &generateSynchronizedStatement),
		Choice(1, &generateTryStatement),
		Choice(1, &generateThrowStatement),
		Choice(1, &generateScopeGuardStatement),
		Choice(1, &generateAsmStatement),
		Choice(1, &generateConditionalStatement),
		Choice(1, &generateStaticAssertStatement),
		Choice(1, &generateVersionSpecification),
		Choice(1, &generateDebugSpecification),
		Choice(10, &generateExpressionStatement)
	]);
}

void generateStaticAssertDeclaration(File f)
{
	generateStaticAssertStatement(f);
}

void generateStaticAssertStatement(File f)
{
	f.write("static ");
	generateAssertExpression(f);
	f.writeln(";");
}

void generateStaticConstructor(File f)
{
	f.writeln("static this()");
	generateFunctionBody(f);
}

void generateStaticDestructor(File f)
{
	f.writeln("static ~this()");
	generateFunctionBody(f);
}

void generateStaticIfCondition(File f)
{
	f.write("static if (");
	generateAssignExpression(f);
	f.write(")");
}

void generateStorageClass(File f)
{
	switch (uniform(0, 19))
	{
	case 0: generateAlignAttribute(f); break;
	case 1: generateLinkageAttribute(f); break;
	case 2: generateAtAttribute(f); break;
	case 3: generateTypeConstructor(f); break;
	case 4: f.write("deprecated"); break;
	case 5: f.write("abstract"); break;
	case 6: f.write("auto"); break;
	case 7: f.write("enum"); break;
	case 8: f.write("extern"); break;
	case 9: f.write("final"); break;
	case 10: f.write("virtual"); break;
	case 11: f.write("nothrow"); break;
	case 12: f.write("override"); break;
	case 13: f.write("pure"); break;
	case 14: f.write("ref"); break;
	case 15: f.write("__gshared"); break;
	case 16: f.write("scope"); break;
	case 17: f.write("static"); break;
	case 18: f.write("synchronized"); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateStructBody(File f)
{
	f.writeln("{");
	foreach (_; 0 .. times(0, 7))
		generateDeclaration(f);
	f.writeln("}");
}

void generateStructDeclaration(File f)
{
	f.write("struct ");
	switch (uniform(0, 4))
	{
	case 0: f.writeln(";"); break;
	case 1: f.writeln(); generateStructBody(f); break;
	case 2:
		generateIdentifier(f);
		if (coinFlip())
		{
			generateTemplateParameters(f);
			if (coinFlip())
			{
				f.write(" ");
				generateConstraint(f);
			}
		}
		f.writeln();
		generateStructBody(f);
		break;
	case 3: generateIdentifier(f); f.writeln(); generateStructBody(f); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateStructInitializer(File f)
{
	f.write("{");
	if (coinFlip())
		generateStructMemberInitializers(f);
	f.write("}");
}

void generateStructMemberInitializer(File f)
{
	if (coinFlip())
	{
		generateIdentifier(f);
		f.write(" : ");
	}
	generateNonVoidInitializer(f);
}

void generateStructMemberInitializers(File f)
{
	generateSeparated!(generateStructMemberInitializer)(1, 5, ",\n", f);
}

void generateSwitchStatement(File f)
{
	f.write("switch (");
	generateExpression(f);
	f.writeln(")");
	generateStatement(f);
}

void generateSymbol(File f)
{
	if (coinFlip())
		f.write(".");
	generateIdentifierOrTemplateChain(f);
}

void generateSynchronizedStatement(File f)
{
	f.write("synchronized");
	if (coinFlip())
	{
		f.write(" (");
		generateExpression(f);
		f.write(")");
	}
	f.writeln();
	generateStatementNoCaseNoDefault(f);
}

void generateTemplateAliasParameter(File f)
{
	f.write("alias ");
	if (coinFlip())
	{
		generateType(f);
		f.write(" ");
	}
	generateIdentifier(f);
	f.write(" ");
	if (coinFlip())
	{
		f.write(": ");
		if (coinFlip())
			generateType(f);
		else
			generateAssignExpression(f);
	}
	if (coinFlip())
	{
		f.write("= ");
		if (coinFlip())
			generateType(f);
		else
			generateAssignExpression(f);
	}
}

void generateTemplateArgument(File f)
{
	arbitraryCall(f, [
		Choice(1, &generateType),
		Choice(1, &generateAssignExpression),
		Choice(10, &generateIdentifier)
	]);
}

void generateTemplateArgumentList(File f)
{
	generateSeparated!(generateTemplateArgument)(1, 5, ", ", f);
}

void generateTemplateArguments(File f)
{
	f.write("!");
	if (coinFlip())
		generateTemplateSingleArgument(f);
	else
	{
		f.write("(");
		if (coinFlip())
			generateTemplateArgumentList(f);
		f.write(")");
	}
}

void generateTemplateDeclaration(File f)
{
	f.write("template ");
	generateIdentifier(f);
	generateTemplateParameters(f);
	if (coinFlip())
	{
		f.write(" ");
		generateConstraint(f);
	}
	f.writeln();
	f.writeln("{");
	foreach (_; 0 .. uniform(0, 5))
		generateDeclaration(f);
	f.writeln("}");
}

void generateTemplateInstance(File f)
{
	generateIdentifier(f);
	generateTemplateArguments(f);
}

void generateTemplateMixinExpression(File f)
{
	f.write("mixin ");
	generateMixinTemplateName(f);
	if (coinFlip())
		generateTemplateArguments(f);
	if (coinFlip())
	{
		f.write(" ");
		generateIdentifier(f);
	}
}

void generateTemplateParameter(File f)
{
	arbitraryCall(f, [
		Choice(1, &generateTemplateTypeParameter),
		Choice(1, &generateTemplateValueParameter),
		Choice(1, &generateTemplateAliasParameter),
		Choice(1, &generateTemplateTupleParameter),
		Choice(1, &generateTemplateThisParameter),
		Choice(10, &generateIdentifier),
	]);
}

void generateTemplateParameterList(File f)
{
	generateSeparated!(generateTemplateParameter)(1, 3, ", ", f);
}

void generateTemplateParameters(File f)
{
	f.write("(");
	if (coinFlip())
		generateTemplateParameterList(f);
	f.write(")");
}

void generateTemplateSingleArgument(File f)
{
	switch (uniform(0, 20))
	{
	case 0: generateBuiltinType(f); break;
	case 1: generateIdentifier(f); break;
	case 2: generateCharacterLiteral(f); break;
	case 3: generateStringLiteral(f); break;
	case 4: generateIntLiteral(f); break;
	case 5: generateFloatLiteral(f); break;
	case 6: f.write("true"); break;
	case 7: f.write("false"); break;
	case 8: f.write("null"); break;
	case 9: f.write("this"); break;
	case 10: f.write("__DATE__"); break;
	case 11: f.write("__TIME__"); break;
	case 12: f.write("__TIMESTAMP__"); break;
	case 13: f.write("__VENDOR__"); break;
	case 14: f.write("__VERSION__"); break;
	case 15: f.write("__FILE__"); break;
	case 16: f.write("__LINE__"); break;
	case 17: f.write("__MODULE__"); break;
	case 18: f.write("__FUNCTION__"); break;
	case 19: f.write("__PRETTY_FUNCTION__"); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateTemplateThisParameter(File f)
{
	f.write("this ");
	generateTemplateTypeParameter(f);
}

void generateTemplateTupleParameter(File f)
{
	generateIdentifier(f);
	f.write("...");
}

void generateTemplateTypeParameter(File f)
{
	generateIdentifier(f);
	if (coinFlip())
	{
		f.write(" : ");
		generateType(f);
	}
	if (coinFlip())
	{
		f.write(" = ");
		generateType(f);
	}
}

void generateTemplateValueParameter(File f)
{
	generateType(f);
	f.write(" ");
	generateIdentifier(f);
	if (coinFlip())
	{
		f.write(" : ");
		generateAssignExpression(f);
	}
	if (coinFlip())
		generateTemplateValueParameterDefault(f);
}

void generateTemplateValueParameterDefault(File f)
{
	f.write(" = ");
	switch (uniform(0, 6))
	{
	case 0: f.write("__FILE__"); break;
	case 1: f.write("__MODULE__"); break;
	case 2: f.write("__LINE__"); break;
	case 3: f.write("__FUNCTION__"); break;
	case 4: f.write("__PRETTY_FUNCTION__"); break;
	case 5: generateAssignExpression(f); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateTernaryExpression(File f)
{
	generateOrOrExpression(f);
	if (dice(95, 5))
	{
		f.write(" ? ");
		generateExpression(f);
		f.write(" : ");
		generateTernaryExpression(f);
	}
}

void generateThrowStatement(File f)
{
	f.write("throw ");
	generateExpression(f);
	f.writeln(";");
}

void generateTraitsExpression(File f)
{
	f.write("__traits(");
	generateIdentifier(f);
	f.write(", ");
	generateTemplateArgumentList(f);
	f.write(")");
}

void generateTryStatement(File f)
{
	f.writeln("try");
	generateDeclarationOrStatement(f);
	switch (uniform(0, 3))
	{
	case 0: generateCatches(f); break;
	case 1: generateCatches(f); generateFinally(f); break;
	case 2: generateFinally(f); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateType(File f)
{
	if (dice(90, 10))
	{
		generateTypeConstructor(f);
		f.write(" ");
	}
	generateType2(f);
	if (dice(90, 10))
		generateSeparated!(generateTypeSuffix)(1, 2, "", f);
}

void generateType2(File f)
{
	arbitraryCall(f, [
		Choice(20, function(File f) {
			generateBuiltinType(f);
		}),
		Choice(10, function(File f) {
			generateSymbol(f);
		}),
		Choice(1, function(File f) {
			generateTypeofExpression(f);
			if (coinFlip())
			{
				f.write(".");
				generateIdentifierOrTemplateChain(f);
			}
		}),
		Choice(1, function(File f) {
			generateTypeConstructor(f);
			f.write("(");
			generateType(f);
			f.write(")");
		}),
		Choice(1, function(File f) {
			generateVector(f);
		})
	]);
}

void generateTypeSpecialization(File f)
{
	switch (uniform(0, 16))
	{
	case 0: f.write("struct"); break;
	case 1: f.write("union"); break;
	case 2: f.write("class"); break;
	case 3: f.write("interface"); break;
	case 4: f.write("enum"); break;
	case 5: f.write("function"); break;
	case 6: f.write("delegate"); break;
	case 7: f.write("super"); break;
	case 8: f.write("return"); break;
	case 9: f.write("typedef"); break;
	case 10: f.write("__parameters"); break;
	case 11: f.write("const"); break;
	case 12: f.write("immutable"); break;
	case 13: f.write("inout"); break;
	case 14: f.write("shared"); break;
	case 15: generateType(f); break;
	default: assert (false, __FUNCTION__);
	}
}

void generateTypeSuffix(File f)
{
	arbitraryCall(f, [
		Choice(20, function (File f) {
			f.write("*");
		}),
		Choice(20, function (File f) {
			f.write("[]");
		}),
		Choice(1, function (File f) {
			f.write("[");
			if (dice(1, 2))
				generateType(f);
			f.write("]");
		}),
		Choice(1, function (File f) {
			f.write("[");
			generateAssignExpression(f);
			f.write("]");
		}),
		Choice(1, function (File f) {
			f.write("[");
			generateAssignExpression(f);
			f.write(" .. ");
			generateAssignExpression(f);
			f.write("]");
		}),
		Choice(1, function (File f) {
			if (coinFlip())
				f.write(" delegate ");
			else
				f.write(" function ");
			generateParameters(f);
			foreach (_; 0 .. dice(60, 30, 10))
			{
				f.write(" ");
				generateMemberFunctionAttribute(f);
			}
		})
	]);
}
void generateTypeidExpression(File f)
{
	f.write("typeid (");
	if (coinFlip())
		generateType(f);
	else
		generateExpression(f);
	f.write(")");
}

void generateTypeofExpression(File f)
{
	f.write("typeof (");
	if (coinFlip())
		generateExpression(f);
	else
		f.write("return");
	f.write(")");
}

void generateUnaryExpression(File f)
{
	arbitraryCall(f, [
		Choice(20, &generatePrimaryExpression),
		Choice(1, function (File f) {
			f.write("&");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("~");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("*");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("+");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("-");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("++");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("--");
			generatePrimaryExpression(f);
		}),
		Choice(1, function (File f) {
			f.write("(");
			generateType(f);
			f.write(").");
			generateIdentifierOrTemplateInstance(f);
		}),
		Choice(1, function (File f) {
			generateUnaryExpression(f);
			f.write(".");
			generateIdentifierOrTemplateInstance(f);
		}),
		Choice(1, function (File f) {
			generateUnaryExpression(f);
			f.write("--");
		}),
		Choice(1, function (File f) {
			generateUnaryExpression(f);
			f.write("++");
		}),
		Choice(1, &generateNewExpression),
		Choice(1, &generateDeleteExpression),
		Choice(1, &generateCastExpression),
		Choice(1, &generateAssertExpression),
		Choice(1, &generateFunctionCallExpression),
		Choice(1, &generateSliceExpression),
		Choice(1, &generateIndexExpression),
	]);
}

void generateUnionDeclaration(File f)
{
	f.writeln("union {}");
}

void generateUnittest(File f)
{
	f.writeln("unittest");
	generateBlockStatement(f);
}

void generateVariableDeclaration(File f)
{
	arbitraryCall(f, [
		Choice(10, function (File f) {
			generateType(f);
			f.write(" ");
			generateSeparated!(generateDeclarator)(1, 2, ", ", f);
			f.writeln(";");
		}),
		Choice(1, function (File f) {
			generateType(f);
			f.write(" ");
			generateDeclarator(f);
			f.write(" = ");
			generateFunctionBody(f);
			f.writeln(";");
		}),
		Choice(5, &generateAutoDeclaration)
	]);
}

void generateVector(File f)
{
	f.write("__vector(");
	generateType(f);
	f.write(")");
}

void generateVersionCondition(File f)
{
	f.write("version (");
	switch (uniform(0, 4))
	{
	case 0: f.write("unittest"); break;
	case 1: f.write("assert"); break;
	case 2: generateIntLiteral(f); break;
	case 3: generateIdentifier(f); break;
	default: assert (false, __FUNCTION__);
	}
	f.write(")");
}

void generateVersionSpecification(File f)
{
	f.write("version = ");
	if (coinFlip())
		generateIdentifier(f);
	else
		generateIntLiteral(f);
	f.writeln(";");
}

void generateWhileStatement(File f)
{
	f.write("while (");
	generateExpression(f);
	f.writeln(")");
	generateStatementNoCaseNoDefault(f);
}

void generateWithStatement(File f)
{
	f.write("with (");
	generateExpression(f);
	f.writeln(")");
	generateStatementNoCaseNoDefault(f);
}

void generateXorExpression(File f)
{
	generateBinaryExpression!(generateXorExpression, generateAndExpression, ["^"])(f);
}
