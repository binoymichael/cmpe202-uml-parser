import org.aspectj.lang.JoinPoint;

public aspect TracingAspect {
	private int callDepth;

  /*pointcut traced() : !within(TracingAspect) && execution(public * *.*(..)); // && cflow(execution(*.new(..)));*/
	/*pointcut constructors() : !within(TracingAspect) && execution(*.new(..)) && !call(java..new(..));*/
  pointcut traced() : !within(TracingAspect) && call(* *.*(..)) && !cflow(execution(*.new(..)));

  /*before() : constructors() {*/
    /*print("Constructor", thisJoinPoint);*/
  /*}*/

  before() : traced() {
    print("Message", thisJoinPoint);
    callDepth++;
  }

	/*after() : traced() {*/
		/*callDepth--;*/
		/*print("After", thisJoinPoint);*/
	/*}*/

	private void print(String prefix, JoinPoint message) {
    
    System.out.println(prefix + ": " + "-----");
		System.out.println("longstring" + ": " + message.toLongString());
		System.out.println("args" + ": " + message.getArgs());
		System.out.println("kind" + ": " + message.getKind());
		System.out.println("signature" + ": " + message.getSignature());
		System.out.println("signature:name" + ": " + message.getSignature().getName());
		System.out.println("source" + ": " + message.getSourceLocation());
    if (message.getTarget() != null) {
      System.out.println("target" + ": " + message.getTarget().getClass());
    }
    else {
      System.out.println("target is null");
    }
    if (message.getThis() != null) {
      System.out.println("this" + ": " + message.getThis().getClass());
    }
    else {
      System.out.println("target is null");
    }
	}
}
