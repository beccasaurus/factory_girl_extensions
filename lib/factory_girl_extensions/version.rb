module FactoryGirlExtensions
  begin
    old, $VERBOSE = $VERBOSE, nil
    VERSION = "2.0.0"
  ensure
    $VERBOSE = old
  end
end
