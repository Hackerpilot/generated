module generated;

import std.random;
import std.stdio;

/**
 * Loops between atLeast and atMost times and choses one of Funcs to execute.
 */
template randomCall(Funcs ...)
{
	void randomCall(Args ...)(uint atLeast, uint atMost, Args args)
	{
		import std.random : uniform;

		string generateMixin()
		{
			import std.string : format;
			string code;
			foreach (i, f; Funcs)
			{
				code ~= "case %s: %s(args); break;\n".format(i, f);
			}
			code ~= "default: assert (false);\n";
			return code;
		}

		foreach (i; 0 .. uniform(atLeast, atMost + 1))
		{
			switch (uniform(0, Funcs.length))
			{
				mixin (generateMixin());
			}
		}
	}
}


void main()
{
	generateModule(stdout);
}

void generateSeparated(alias functionName)(uint t, string separator, File f)
{
	uint n = uniform(1, t);
	foreach (i; 0 .. n)
	{
		functionName(f);
		if (i + 1 < n)
			f.write(separator);
	}
}

void generateBuiltinType(File f)
{
	auto builtinTypes = ["int", "uint", "double", "idouble", "float", "ifloat",
		"short", "ushort", "long", "ulong", "char", "wchar", "dchar", "bool",
		"void", "cent", "ucent", "real", "ireal", "byte", "ubyte", "cdouble",
		"cfloat", "creal"];
	f.write(randomSample(builtinTypes, 1).front);
}

void generateTypeConstructor(File f)
{
	auto typeConstructors = ["const", "immutable", "inout", "shared", "scope",
		"ref", "pure", "nothrow"];
	f.write(randomSample(typeConstructors, 1).front);
}

bool coinFlip()
{
	return uniform(0, 2) == 1;
}

void generateIdentifier(File f)
{
	f.write("ident");
}

void generateStringLiteral(File f)
{
	f.write("\"stringLiteral\"");
}

void generateFloatLiteral(File f)
{
	f.write("42.0");
}

void generateIntLiteral(File f)
{
	f.write("42");
}

void generateAddExpression(File f) {}
void generateAliasDeclaration(File f) {}
void generateAliasInitializer(File f) {}

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

void generateAndAndExpression(File f) {}
void generateAndExpression(File f) {}
void generateArgumentList(File f) {}
void generateArguments(File f) {}
void generateArrayInitializer(File f) {}
void generateArrayLiteral(File f) {}
void generateArrayMemberInitialization(File f) {}
void generateAsmAddExp(File f) {}
void generateAsmAndExp(File f) {}
void generateAsmBrExp(File f) {}
void generateAsmEqualExp(File f) {}
void generateAsmExp(File f) {}
void generateAsmInstruction(File f) {}
void generateAsmLogAndExp(File f) {}
void generateAsmLogOrExp(File f) {}
void generateAsmMulExp(File f) {}
void generateAsmOrExp(File f) {}
void generateAsmPrimaryExp(File f) {}
void generateAsmRelExp(File f) {}
void generateAsmShiftExp(File f) {}
void generateAsmStatement(File f) {}
void generateAsmTypePrefix(File f) {}
void generateAsmUnaExp(File f) {}
void generateAsmXorExp(File f) {}
void generateAssertExpression(File f) {}
void generateAssignExpression(File f) {}
void generateAssocArrayLiteral(File f) {}
void generateAtAttribute(File f) {}
void generateAttribute(File f) {}
void generateAttributeDeclaration(File f) {}
void generateAutoDeclaration(File f) {}
void generateBlockStatement(File f) {}
void generateBodyStatement(File f) {}
void generateBreakStatement(File f) {}

void generateBaseClass(File f)
{
	generateType2(f);
}

void generateBaseClassList(File f)
{
	generateSeparated!(generateBaseClass)(4, ", ", f);
}

void generateCaseRangeStatement(File f) {}
void generateCaseStatement(File f) {}
void generateCastExpression(File f) {}
void generateCastQualifier(File f) {}
void generateCatch(File f) {}
void generateCatches(File f) {}
void generateClassDeclaration(File f)
{
	f.write("class ");
	generateIdentifier(f);
	if (coinFlip())
	{
		generateTemplateParameters(f);
		if (coinFlip())
			generateConstraint(f);
	}
	if (coinFlip())
	{
		f.write(" : ");
		generateBaseClassList(f);
		f.write(" ");
	}
	if (coinFlip())
		f.writeln(";");
	else
	{
		f.writeln();
		generateStructBody(f);
	}
}

void generateCmpExpression(File f) {}
void generateCompileCondition(File f) {}
void generateConditionalDeclaration(File f) {}
void generateConditionalStatement(File f) {}
void generateConstraint(File f) {}
void generateConstructor(File f) {}
void generateContinueStatement(File f) {}
void generateDebugCondition(File f) {}
void generateDebugSpecification(File f) {}

void generateDeclaration(File f)
{
	randomCall!("generateAttribute")(0, 6, f);
	randomCall!("generateAliasDeclaration",
		"generateAliasThisDeclaration",
		"generateClassDeclaration",
		"generateConditionalDeclaration",
		"generateConstructor",
		"generateDestructor",
		"generateEnumDeclaration",
		"generateFunctionDeclaration",
		"generateImportDeclaration",
		"generateInterfaceDeclaration",
		"generateMixinDeclaration",
		"generateMixinTemplateDeclaration",
		"generatePragmaDeclaration",
		"generateSharedStaticConstructor",
		"generateSharedStaticDestructor",
		"generateStaticAssertDeclaration",
		"generateStaticConstructor",
		"generateStaticDestructor",
		"generateStructDeclaration",
		"generateTemplateDeclaration",
		"generateUnionDeclaration",
		"generateUnittest",
		"generateVariableDeclaration",
		"generateAttributeDeclaration",
		"generateInvariant",
		"generateVersionSpecification",
		"generateDebugSpecification"
		)(1, 1, f);
}
void generateDeclarationOrStatement(File f) {}
void generateDeclarationsAndStatements(File f) {}
void generateDeclarator(File f) {}
void generateDefaultStatement(File f) {}
void generateDeleteExpression(File f) {}
void generateDeleteStatement(File f) {}

void generateDeprecated(File f)
{
	f.write("deprecated");
	if (coinFlip())
	{
		f.write("(");
		generateAssignExpression(f);
		f.write(")");
	}
	f.write(" ");
}

void generateDestructor(File f) {}
void generateDoStatement(File f) {}
void generateEnumBody(File f) {}
void generateEnumDeclaration(File f) {}
void generateEnumMember(File f) {}
void generateEponymousTemplateDeclaration(File f) {}
void generateEqualExpression(File f) {}
void generateExpression(File f) {}
void generateExpressionStatement(File f) {}
void generateFinalSwitchStatement(File f) {}
void generateFinally(File f) {}
void generateForStatement(File f) {}
void generateForeachStatement(File f) {}
void generateForeachType(File f) {}
void generateForeachTypeList(File f) {}
void generateFunctionAttribute(File f) {}
void generateFunctionBody(File f) {}
void generateFunctionCallExpression(File f) {}
void generateFunctionDeclaration(File f) {}
void generateFunctionLiteralExpression(File f) {}
void generateGotoStatement(File f) {}

void generateIdentifierChain(File f)
{
	generateSeparated!(generateIdentifier)(6, ".", f);
}

void generateIdentifierList(File f) {}
void generateIdentifierOrTemplateChain(File f) {}
void generateIdentifierOrTemplateInstance(File f) {}
void generateIdentityExpression(File f) {}
void generateIfStatement(File f) {}
void generateImportBind(File f) {}
void generateImportBindings(File f) {}
void generateImportDeclaration(File f) {}
void generateImportExpression(File f) {}
void generateIndexExpression(File f) {}
void generateInExpression(File f) {}
void generateInStatement(File f) {}
void generateInitialize(File f) {}
void generateInitializer(File f) {}
void generateInterfaceDeclaration(File f) {}
void generateInvariant(File f) {}
void generateIsExpression(File f) {}
void generateKeyValuePair(File f) {}
void generateKeyValuePairs(File f) {}
void generateLabeledStatement(File f) {}
void generateLambdaExpression(File f) {}
void generateLastCatch(File f) {}
void generateLinkageAttribute(File f) {}
void generateMemberFunctionAttribute(File f) {}
void generateMixinDeclaration(File f) {}
void generateMixinExpression(File f) {}
void generateMixinTemplateDeclaration(File f) {}
void generateMixinTemplateName(File f) {}

void generateModule(File f)
{
	randomCall!("generateModuleDeclaration")(0, 1, f);
	randomCall!("generateDeclaration")(0, 20, f);
}

void generateModuleDeclaration(File f)
{
	randomCall!("generateDeprecated")(0, 1, f);
	f.write("module ");
	generateIdentifierChain(f);
	f.writeln(";");
}

void generateMulExpression(File f) {}
void generateNewAnonClassExpression(File f) {}
void generateNewExpression(File f) {}
void generateNonVoidInitializer(File f) {}
void generateOperands(File f) {}
void generateOrExpression(File f) {}
void generateOrOrExpression(File f) {}
void generateOutStatement(File f) {}
void generateParameter(File f) {}
void generateParameters(File f) {}
void generatePostblit(File f) {}
void generatePostIncDecExpression(File f) {}
void generatePowExpression(File f) {}
void generatePragmaDeclaration(File f) {}
void generatePragmaExpression(File f) {}
void generatePreIncDecExpression(File f) {}
void generatePrimaryExpression(File f) {}
void generateRegister(File f) {}
void generateRelExpression(File f) {}
void generateReturnStatement(File f) {}
void generateScopeGuardStatement(File f) {}
void generateSharedStaticConstructor(File f) {}
void generateSharedStaticDestructor(File f) {}
void generateShiftExpression(File f) {}
void generateSingleImport(File f) {}
void generateSliceExpression(File f) {}
void generateStatement(File f) {}
void generateStatementNoCaseNoDefault(File f) {}
void generateStaticAssertDeclaration(File f) {}
void generateStaticAssertStatement(File f) {}
void generateStaticConstructor(File f) {}
void generateStaticDestructor(File f) {}
void generateStaticIfCondition(File f) {}
void generateStorageClass(File f) {}

void generateStructBody(File f)
{
	f.writeln("{");
	randomCall!("generateDeclaration")(0, 10, f);
	f.writeln("}");
}

void generateStructDeclaration(File f) {}
void generateStructInitializer(File f) {}
void generateStructMemberInitializer(File f) {}
void generateStructMemberInitializers(File f) {}
void generateSwitchStatement(File f) {}
void generateSymbol(File f) {}
void generateSynchronizedStatement(File f) {}
void generateTemplateAliasParameter(File f) {}
void generateTemplateArgument(File f) {}
void generateTemplateArgumentList(File f) {}
void generateTemplateArguments(File f) {}
void generateTemplateDeclaration(File f) {}
void generateTemplateInstance(File f) {}
void generateTemplateMixinExpression(File f) {}
void generateTemplateParameter(File f) {}
void generateTemplateParameterList(File f) {}
void generateTemplateParameters(File f) {}
void generateTemplateSingleArgument(File f) {}
void generateTemplateThisParameter(File f) {}
void generateTemplateTupleParameter(File f) {}
void generateTemplateTypeParameter(File f) {}
void generateTemplateValueParameter(File f) {}
void generateTemplateValueParameterDefault(File f) {}
void generateTernaryExpression(File f) {}
void generateThrowStatement(File f) {}
void generateToken(File f) {}
void generateTraitsExpression(File f) {}
void generateTryStatement(File f) {}
void generateType(File f) {}

void generateType2(File f)
{
	switch (uniform(0, 5))
	{
	case 0: generateBuiltinType(f); break;
	case 1: generateSymbol(f); break;
	case 2:
		generateTypeofExpression(f);
		if (coinFlip())
		{
			f.write(".");
			generateIdentifierOrTemplateChain(f);
		}
		break;
	case 3:
		generateTypeConstructor(f);
		f.write("(");
		generateType(f);
		f.write(")");
		break;
	case 4: generateVector(f); break;
	default: assert (false);
	}
}

void generateTypeSpecialization(File f) {}
void generateTypeSuffix(File f) {}
void generateTypeidExpression(File f) {}
void generateTypeofExpression(File f) {}
void generateUnaryExpression(File f) {}
void generateUnionDeclaration(File f) {}
void generateUnittest(File f) {}
void generateVariableDeclaration(File f) {}
void generateVector(File f) {}
void generateVersionCondition(File f) {}
void generateVersionSpecification(File f) {}
void generateWhileStatement(File f) {}
void generateWithStatement(File f) {}
void generateXorExpression(File f) {}
