use v6.c;
use lib $?FILE.IO.parent(3).add: 'packages';
use Test;
use Test::Util;

plan 18;

# This appendix contains features that may already exist in some implementations but the exact
# behaviour is currently not fully decided on.

{
    # This once wrongly reported a multi-dispatch circularity.
    multi rt107638(int $a) { 'ok' }      #OK not used
    multi rt107638(Str $a where 1) { }   #OK not used
    lives-ok { rt107638(1) },
        'native types and where clauses do not cause spurious circularities';
}

subtest ':D DefiniteHow target (core types)' => {
    #####
    # XXX 6.e REVIEW: some of these might be overly specific.
    # E.g. :U<->:D coersions might be over-engineering that we should never implement, as even
    # basic type checks of coersions are rather costly (we don't yet do them in Rakudo)
    #####
    plan 8;
    is-deeply -> Int:D(Cool)   $x { $x }("42"), 42, 'type';
    is-deeply -> Int:D(Cool:D) $x { $x }("42"), 42, ':D smiley';
    is-deeply -> Int:D()       $x { $x }("42"), 42, 'implied Any';
    #?rakudo skip ':D/:U coerces NYI'
    is-deeply -> Array:D(List:U) $x { $x }(List), [List,], ':U smiley';

    is-deeply -> Int:D(Cool)   $x { $x }("42"), 42, 'type';
    is-deeply -> Int:D(Cool:D) $x { $x }("42"), 42, ':D smiley';
    is-deeply -> Int:D()       $x { $x }("42"), 42, 'implied Any';
    #?rakudo skip ':D/:U coerces NYI'
    is-deeply -> Array:D(List:U) $x { $x }(List), [List,], ':U smiley';
}

subtest ':U DefiniteHow target (core types)' => {
    plan 3;
    is-deeply -> Date:U(DateTime)   $x { $x }(DateTime), Date, 'type';
    is-deeply -> Date:U(DateTime:U) $x { $x }(DateTime), Date, ':U smiley';
    is-deeply -> Date:U()       $x { $x }(DateTime), Date, 'implied Any';
}

subtest 'DefiniteHow target, errors' => {
    #####
    # XXX 6.e REVIEW: some of these might be overly specific.
    # E.g. :U<->:D coersions might be over-engineering that we should never implement, as even
    # basic type checks of coersions are rather costly (we don't yet do them in Rakudo)
    #####
    plan 4;
    my \XPIC = X::Parameter::InvalidConcreteness;
    #?rakudo 4 todo 'no proper concreteness check in coerces'
    throws-like ｢-> Date:D(DateTime)   {}(DateTime)｣, XPIC, 'type, bad source';
    throws-like ｢-> Date:D(DateTime:D) {}(DateTime)｣, XPIC, ':D, bad source';
    throws-like ｢-> Date:D(DateTime:U) {}(DateTime)｣, XPIC, ':U, bad target';
    throws-like ｢-> Date:D() {}(DateTime)｣, XPIC, 'implied, bad target';
}

subtest 'DefiniteHow target, errors, source is already target' => {
    #####
    # XXX 6.e REVIEW: some of these might be overly specific.
    # E.g. :U<->:D coersions might be over-engineering that we should never implement, as even
    # basic type checks of coersions are rather costly (we don't yet do them in Rakudo)
    #####
    plan 4;
    my \XPIC = X::Parameter::InvalidConcreteness;
    #?rakudo 4 todo 'no proper concreteness check in coerces'
    throws-like ｢-> Date:D(DateTime)   {}(Date)｣, XPIC, 'type';
    throws-like ｢-> Date:D(DateTime:D) {}(Date)｣, XPIC, ':D';
    throws-like ｢-> Date:D(DateTime:U) {}(Date)｣, XPIC, ':U';
    throws-like ｢-> Date:D() {}(Date)｣,           XPIC, 'implied';
}

{
    #####
    # XXX 6.e REVIEW: some of these might be overly specific.
    # E.g. :U<->:D coersions might be over-engineering that we should never implement, as even
    # basic type checks of coersions are rather costly (we don't yet do them in Rakudo)
    #####
    my class Target {...}
    my class Source  { method Target { self.DEFINITE ?? Target.new !! Target } }
    my class SourceU { method Target { self.DEFINITE ?? Target !! Target.new } }
    my class Target is Source is SourceU {}
    my class SubSource  is Source  {}
    my class SubSourceU is SourceU {}

    subtest ':D DefiniteHow target (arbitrary types; from source)' => {
        plan 6;
        is-deeply -> Target:D(Source)   $x { $x }(Source.new), Target.new,
            'from type';
        is-deeply -> Target:D(Source:D) $x { $x }(Source.new), Target.new,
            'from :D smiley';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:D(Source:U) $x { $x }(SourceU),    Target.new,
            'from :U smiley';
        is-deeply -> Target:D(Any)      $x { $x }(Source.new), Target.new,
            'from Any';
        is-deeply -> Target:D(Any:D)    $x { $x }(Source.new), Target.new,
            'from Any:D';

        # https://github.com/rakudo/rakudo/issues/1361
        is-deeply -> Target:D()         $x { $x }(Source.new), Target.new,
            'from implied Any';
    }

    subtest ':D DefiniteHow target (arbitrary types; from source subclass)' => {
        plan 6;
        is-deeply -> Target:D(Source)   $x { $x }(SubSource.new), Target.new,
            'from type';
        is-deeply -> Target:D(Source:D) $x { $x }(SubSource.new), Target.new,
            'from :D smiley';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:D(Source:U) $x { $x }(SubSourceU),    Target.new,
            'from :U smiley';
        is-deeply -> Target:D(Any)      $x { $x }(SubSource.new), Target.new,
            'from Any';
        is-deeply -> Target:D(Any:D)    $x { $x }(SubSource.new), Target.new,
            'from Any:D';
        is-deeply -> Target:D()         $x { $x }(SubSource.new), Target.new,
            'from implied Any';
    }

    subtest ':D DefiniteHow target (arbitrary types; already target)' => {
        plan 6;
        is-deeply -> Target:D(Source)   $x { $x }(Target.new), Target.new,
            'from type';
        is-deeply -> Target:D(Source:D) $x { $x }(Target.new), Target.new,
            'from :D smiley';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:D(Source:U) $x { $x }(Target.new), Target.new,
            'from :U smiley';
        is-deeply -> Target:D(Any)      $x { $x }(Target.new), Target.new,
            'from Any';
        is-deeply -> Target:D(Any:D)    $x { $x }(Target.new), Target.new,
            'from Any:D';
        is-deeply -> Target:D()         $x { $x }(Target.new), Target.new,
            'from implied Any';
    }

    subtest ':U DefiniteHow target (arbitrary types; from source)' => {
        plan 6;
        is-deeply -> Target:U(Source)   $x { $x }(Source),      Target,
            'from type';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:U(Source:D) $x { $x }(SourceU.new), Target,
            'from :D smiley';
        is-deeply -> Target:U(Source:U) $x { $x }(Source),      Target,
            'from :U smiley';
        is-deeply -> Target:U(Any)      $x { $x }(Source),      Target,
            'from Any';
        is-deeply -> Target:U(Any:U)    $x { $x }(Source),      Target,
            'from Any:U';
        is-deeply -> Target:U()         $x { $x }(Source),      Target,
            'from implied Any';
    }

    subtest ':U DefiniteHow target (arbitrary types; from source subclass)' => {
        plan 6;
        is-deeply -> Target:U(Source)   $x { $x }(SubSource),      Target,
            'from type';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:U(Source:D) $x { $x }(SubSourceU.new), Target,
            'from :D smiley';
        is-deeply -> Target:U(Source:U) $x { $x }(SubSource),      Target,
            'from :U smiley';
        is-deeply -> Target:U(Any)      $x { $x }(SubSource),      Target,
            'from Any';
        is-deeply -> Target:U(Any:U)    $x { $x }(SubSource),      Target,
            'from Any:U';
        is-deeply -> Target:U()         $x { $x }(SubSource),      Target,
            'from implied Any';
    }

    subtest ':U DefiniteHow target (arbitrary types; already target)' => {
        plan 6;
        is-deeply -> Target:U(Source)   $x { $x }(Target), Target,
            'from type';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:U(Source:D) $x { $x }(Target), Target,
            'from :D smiley';
        is-deeply -> Target:U(Source:U) $x { $x }(Target), Target,
            'from :U smiley';
        is-deeply -> Target:U(Any)      $x { $x }(Target), Target,
            'from Any';
        #?rakudo skip ':D/:U coerces NYI'
        is-deeply -> Target:U(Any:D)    $x { $x }(Target), Target,
            'from Any:D';
        is-deeply -> Target:U()         $x { $x }(Target), Target,
            'from implied Any';
    }
}

subtest 'mistyped typenames in coercers give good error' => {
    plan 2;
    ok 1; ok 1;
    # sub test-it { throws-like $^code, X::Undeclared::Symbols, $code }
    # subtest 'in signature' => {
    #     plan +my @tests = «
    #       ｢sub (Int(Coor))      {}｣
    #       ｢sub (Innt(Cool))     {}｣
    #       ｢sub (Innt(Coor))     {}｣
    #
    #       ｢sub (Int(Coor:D))    {}｣
    #       ｢sub (Int:D(Coor))    {}｣
    #       ｢sub (Int:D(Coor:D))  {}｣
    #
    #       ｢sub (Innt(Cool:D))   {}｣
    #       ｢sub (Innt:D(Cool))   {}｣
    #       ｢sub (Innt(Cool:D))   {}｣
    #
    #       ｢sub (Innt(Coor:D))   {}｣
    #       ｢sub (Innt:D(Coor))   {}｣
    #       ｢sub (Innt:D(Coor:D)) {}｣
    #     »;
    #     .&test-it for @tests;
    # }
    #
    # subtest 'standalone' => {
    #     plan +my @tests = «
    #       ｢my $x = Int(Coor)｣    ｢my $x = Innt(Cool)｣   ｢my $x = Innt(Coor)｣
    #       ｢my $x = Int(Coor:D)｣  ｢my $x = Int:D(Coor)｣  ｢my $x = Int:D(Coor:D)｣
    #       ｢my $x = Innt(Cool:D)｣ ｢my $x = Innt:D(Cool)｣ ｢my $x = Innt(Cool:D)｣
    #       ｢my $x = Innt(Coor:D)｣ ｢my $x = Innt:D(Coor)｣ ｢my $x = Innt:D(Coor:D)｣
    #     »;
    #     .&test-it for @tests;
    # }
}

# RT #129799
{
    is-deeply Date.new("2016-10-03").IO, "2016-10-03".IO, '.IO on Date';
    is-deeply DateTime.new("2016-10-03T22:23:24Z").IO,
        "2016-10-03T22:23:24Z".IO, '.IO on DateTime';

    throws-like { Date    .IO }, Exception, ".IO on Date:U throws";
    throws-like { DateTime.IO }, Exception, ".IO on DateTime:U throws";
}

# RT #128964
#?rakudo.jvm skip 'RT #128964 Type check failed for return value; expected Str(Any) but got Int (42)'
#?DOES 1
{
    # in SAP due to https://github.com/rakudo/rakudo/issues/2452
    subtest 'type coercions work in returns' => {
        plan 8;

        subtest 'sub (Int --> Str())' => {
            plan 3;

            my sub     t (Int $x --> Str()) {$x}
            isa-ok     t(42),     Str,      'returns correct type';
            is         t(42),     "42",     'returns correct value';
            is-deeply &t.returns, Str(Any), '.returns() gives correct value';
        }

        subtest 'sub (Num $x --> Int(Str))' => {
            plan 3;

            my sub     t (Num $x --> Int(Str)) {"$x"}
            isa-ok     t(42e0),   Int,      'returns correct type';
            is         t(42e0),   42,       'returns correct value';
            is-deeply &t.returns, Int(Str), '.returns() gives correct value';
        }

        subtest 'sub (Int) returns Str()' => {
            plan 3;

            my sub     t (Int $x) returns Str() {$x}
            isa-ok     t(42),     Str,      'returns correct type';
            is         t(42),     "42",     'returns correct value';
            is-deeply &t.returns, Str(Any), '.returns() gives correct value';
        }

        subtest 'sub (Num) returns Int(Str)' => {
            plan 3;

            my sub     t (Num $x) returns Int(Str) {"$x"}
            isa-ok     t(42e0),   Int,      'returns correct type';
            is         t(42e0),   42,       'returns correct value';
            is-deeply &t.returns, Int(Str), '.returns() gives correct value';
        }

        subtest 'block Int --> Str()' => {
            plan 3;

            my        $block = -> Int $x --> Str() {$x};
            isa-ok    $block(42),     Str,      'returns correct type';
            is        $block(42),     "42",     'returns correct value';
            is-deeply $block.returns, Str(Any), '.returns() gives correct value';
        }

        subtest 'block --> Str()' => {
            plan 3;

            my        $block = -> --> Str() {42};
            isa-ok    $block(),       Str,      'returns correct type';
            is        $block(),       "42",     'returns correct value';
            is-deeply $block.returns, Str(Any), '.returns() gives correct value';
        }

        subtest 'method (Int --> Str())' => {
            plan 3;

            my        $o = class { method v (Int $x --> Str()) {$x} }.new;
            isa-ok    $o.v(42), Str,  'returns correct type';
            is        $o.v(42), "42", 'returns correct value';
            is-deeply $o.^find_method('v').returns, Str(Any),
                '.returns() gives correct value';
        }

        throws-like { sub (--> Str(Int)) { 42e0 }() }, X::TypeCheck::Return,
            'returning incorrect type throws';
    }
}

{ # coverage; 2016-09-21
    # in SAP due to https://github.com/rakudo/rakudo/issues/2442
    my $x = Array;
    cmp-ok $x.flat,  '===', $x, 'Array:U.flat is identity';
}