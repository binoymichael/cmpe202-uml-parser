/**
 * @assoc - - 0..1 ConcreteSubject
 */
public class ConcreteObserver implements Observer
{
	public ConcreteObserver(ConcreteSubject theSubject);
	public void update();
	public void showState();
}

/**
 * @assoc - - * Observer
 * @depend - - - Observer
 */
public class ConcreteSubject implements Subject
{
	private String subjectState;
	public String getState();
	public void setState(String status);
	public void attach(Observer obj);
	public void detach(Observer obj);
	public void notifyObservers();
	public void showState();
}

/**
 */
public interface Observer
{
	public void update();
}

/**
 */
public class Optimist extends ConcreteObserver
{
	public Optimist(ConcreteSubject sub);
	public void update();
}

/**
 */
public class Pessimist extends ConcreteObserver
{
	public Pessimist(ConcreteSubject sub);
	public void update();
}

/**
 */
public interface Subject
{
	public void attach(Observer obj);
	public void detach(Observer obj);
	public void notifyObservers();
}

/**
 */
public class TheEconomy extends ConcreteSubject
{
	public TheEconomy();
}

