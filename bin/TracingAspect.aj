import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.Signature;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Stack;
import java.util.LinkedHashSet;
import java.util.ArrayList;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.nio.file.Files;
import java.nio.charset.Charset;
import java.io.IOException;

public aspect TracingAspect {

  LinkedHashSet<String> objects = new LinkedHashSet<String>();
  ArrayList<String> messages = new ArrayList<String>();
  String mainClass = "";
	private int callDepth;

  pointcut mainCall() : !within(TracingAspect) && 
                        execution(public static void main(..));

  pointcut traced() : !within(TracingAspect) && 
                      call(* *.*(..)) && 
                      !call(* java..*.*(..)) && 
                      !cflow(execution(*.new(..)));

  before() : mainCall() {
    mainClass = thisJoinPoint.getSourceLocation().getWithinType().getName();
    objects.add(mainClass);

    messages.add("step();");
    messages.add("active(Main);");
    messages.add("step();");

  }

  before() : traced() {
    beforeMethodCall(thisJoinPoint);
  }

  after() : traced() {
    afterMethodCall(thisJoinPoint);
  }

	private void beforeMethodCall(JoinPoint joinPoint) {
    String self = null;
    if (joinPoint.getThis() != null) {
      self = joinPoint.getThis().getClass().getName();
    }
    else {
      self = mainClass;
    }
    objects.add(self);

    String target = null; 
    if (joinPoint.getTarget() != null) {
      target = joinPoint.getTarget().getClass().getName();
    }
    else {
      target = mainClass;
    }
    objects.add(self);

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

    messages.add("message(" + self + "," + target + "," + "\"" + message + "\"" + ");");
    messages.add("active(" + target + ");");
    messages.add("step();");
	}

	private void afterMethodCall(JoinPoint joinPoint) {
    String target = null; 
    if (joinPoint.getTarget() != null) {
      target = joinPoint.getTarget().getClass().getName();
    }
    else {
      target = "Main";
    }
    messages.add("inactive(" + target + ");");
    messages.add("step();");
  }

  after() : mainCall() {
    messages.add("inactive(" + mainClass + ");");
    ArrayList<String> output = new ArrayList<String>();    
    output.add(".PS");
    output.add("copy \"sequence.pic\";");
    for(String object : objects ) 
    {
        output.add("object(" + object + ",\"" + object + "\");");
    }
    output.addAll(messages);
    for(String object : objects ) 
    {
        output.add("complete(" + object + ");");
    }
    output.add(".PE");

    Path file = Paths.get("uml.pic");
    try {
        Files.write(file, output, Charset.forName("UTF-8"));
    } catch(IOException ie) {
        ie.printStackTrace();
        System.exit(1);
    }

  }

}
