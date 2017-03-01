 

import java.util.Collection;

public class A {
 
  private int x;
   
  private int[] y;
   
  private Collection<B> b;
	 
	private C c;
	 
	private Collection<D> d;
	 
}
 
//{"A"=>{:type=>:class, :modifier=>"public", :children=>{"x"=>{:modifier=>"private", :type=>"int"}, "y"=>{:modifier=>"private", :type=>"int[]"}, "b"=>{:modifier=>"private", :type=>"Collection<B>"}, "c"=>{:modifier=>"private", :type=>"C"}, "d"=>{:modifier=>"private", :type=>"Collection<D>"}}}}
