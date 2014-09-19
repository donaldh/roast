use v6;
use lib 't/spec/packages';

use Test;
use Test::Tap;

plan 5;

dies_ok { Supply.words }, 'can not be called as a class method';

for ThreadPoolScheduler.new, CurrentThreadScheduler -> $*SCHEDULER {
    diag "**** scheduling with {$*SCHEDULER.WHAT.perl}";

    tap_ok Supply.for(<a bb ccc dddd eeeee>).words,
      ['abbcccddddeeeee'],
      "handle a simple list of words";

    {
        my $s = Supply.new;
        tap_ok $s.words,
          [<a b cc d eeee fff>],
          "handle chunked lines",
          :after-tap( {
              $s.more( "   a b c" );
              $s.more( "c d " );
              $s.more( " e" );
              $s.more( "eee" );
              $s.more( "   " );
              $s.more( " fff  " );
              $s.done;
          } );
    }
}
