use v6;

module Export_PackA {
  our sub exported_foo () is export {
    42;
  }
}
