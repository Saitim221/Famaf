package grupo39.namedEntities.heuristics;
import java.io.Serializable;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// public class  FatherHeuristic extends Serializable{

    

// }
public class Heuristics implements  Serializable {
    private   List<String> candidates;

    public Heuristics() {
        candidates = new ArrayList<>();
    }
    
    public List<String> DoHeuristic (String text, String name){
        //System.out.println("entro a do");
        text = text.replaceAll("[-+^:,\"]", "");
        if(!Objects.equals(name, "AfterPoint")) text.replaceAll(".", "");
        text = Normalizer.normalize(text, Normalizer.Form.NFD);
        text = text.replaceAll("\\p{M}", "");
        Pattern pattern = Pattern.compile("[A-Z][a-z]+(?:\\s[A-Z][a-z]+)*");
        Matcher matcher = pattern.matcher(text);
        //System.out.println(text);
        switch(name){
            case "AfterPoint" -> AfterPoint(matcher,text);
            case "CapitalizedWord" -> CapitalizedWordHeuristic(matcher);
            case "TwoTimes" -> TwoTimes(matcher, text);
            default -> {
                System.out.println("Invalid heuristic name");
                System.out.println("Valid heuristics names are:");
                System.out.println("    -CapitalizedWord");
                System.out.println("    -AfterPoint");
                System.out.println("    -TwoTimes");
            }
        }
        //System.out.println(candidates.size());
        return candidates;
  
    }

    private  void AfterPoint (Matcher matcher,String text){
        while (matcher.find()) {
            int start = matcher.start();
            String candidate = (matcher.group());
            if (start >= 2 && text.charAt(start - 2) != '.') {
                candidates.add(candidate);
            }
        }
    }

    private  void CapitalizedWordHeuristic (Matcher matcher){
        //System.out.println("entro a capitalized");
        while (matcher.find()) {
            candidates.add(matcher.group());
        }
        //System.out.println("salio del while");

    }
    
    private   void TwoTimes (Matcher matcher, String text){
        while (matcher.find()) {
            candidates.add(matcher.group());
        }

        for (int i = candidates.size() - 1; i >= 0; i--) {
            String candidate = candidates.get(i);
            if (text.contains(candidate.toLowerCase())) {
                candidates.remove(i);
            }
        }
    }
}