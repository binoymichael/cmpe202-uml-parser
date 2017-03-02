/**
 */
public interface Component
{
	public String operation();
}

/**
 */
public class ConcreteComponent implements Component
{
	public String operation();
}

/**
 * @depend - - - Component
 */
public class ConcreteDecoratorA extends Decorator
{
	private String addedState;
	public void ConcreteDecoratorA(Component c);
	public String operation();
}

/**
 * @depend - - - Component
 */
public class ConcreteDecoratorB extends Decorator
{
	private String addedState;
	public void ConcreteDecoratorB(Component c);
	public String operation();
}

/**
 * @assoc - - 0..1 Component
 * @depend - - - Component
 */
public class Decorator implements Component
{
	public void Decorator(Component c);
	public String operation();
}

/**
 * @depend - - - Component
 */
public class Tester
{
	public void main(String[] args);
}

