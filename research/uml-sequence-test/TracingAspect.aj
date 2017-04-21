import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.Signature;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Stack;

public aspect TracingAspect {

	private int callDepth;

  pointcut mainCall() : !within(TracingAspect) && 
                        execution(public static void main(..));

  pointcut traced() : !within(TracingAspect) && 
                      call(* *.*(..)) && 
                      !call(* java..*.*(..)) && 
                      !cflow(execution(*.new(..)));

  before() : mainCall() {
    System.out.println(thisJoinPoint);
    JoinPoint message = thisJoinPoint;
    System.out.println("longstring" + ": " + message.toLongString());
               System.out.println("args" + ": " + message.getArgs());
               System.out.println("kind" + ": " + message.getKind());
               System.out.println("signature" + ": " + message.getSignature());
               System.out.println("signature:name" + ": " + message.getSignature().getName());
               System.out.println("source" + ": " + message.getSourceLocation());
  }
  after() : mainCall() {
    System.out.println("the end");
  }

  before() : traced() {
    beforeMethodCall(thisJoinPoint);
  }

  after() : traced() {
    /*afterMethodCall(thisJoinPoint);*/
  }

	private void beforeMethodCall(JoinPoint joinPoint) {
    String self = null;
    if (joinPoint.getThis() != null) {
      self = joinPoint.getThis().getClass().getName();
    }
    else {
      self = "Main";
    }

    String target = null; 
    if (joinPoint.getTarget() != null) {
      target = joinPoint.getTarget().getClass().getName();
    }
    else {
      target = "Main";
    }

    Signature methodSignature = joinPoint.getSignature();
    String modifier = methodSignature.toString().split(" ")[0];
    String parameters = null;
    Pattern pattern = Pattern.compile("\\(.*\\)");
    Matcher matcher = pattern.matcher(methodSignature.toString());
    if (matcher.find()) {
      parameters = matcher.group();
    }
    String methodName = methodSignature.getName();
    String message = methodName + ((parameters != null) ? parameters : "") + " : " + modifier;

    System.out.println("message(" + self + "," + target + "," + "\"" + message + "\"" + ");");
    System.out.println("active(" + target + ");");
    System.out.println("step();");
	}

	private void afterMethodCall(JoinPoint joinPoint) {
    String target = null; 
    if (joinPoint.getTarget() != null) {
      target = joinPoint.getTarget().getClass().getName();
    }
    else {
      target = "Main";
    }
    System.out.println("inactive(" + target + ");");
    System.out.println("step();");
  }

}
