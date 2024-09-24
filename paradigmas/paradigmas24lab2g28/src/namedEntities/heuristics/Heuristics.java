package namedEntities.heuristics;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import namedEntities.NamedEntity;

public class Heuristics {
    private static List<String> candidates;

    public Heuristics() {
        candidates = new ArrayList<>();
    }
    
    public List<String> DoHeuristic (String text, String name){
        text = text.replaceAll("[-+^:,\"]", "");
        if(!Objects.equals(name, "AfterPoint")) text.replaceAll(".", "");
        text = Normalizer.normalize(text, Normalizer.Form.NFD);
        text = text.replaceAll("\\p{M}", "");
        Pattern pattern = Pattern.compile("[A-Z][a-z]+(?:\\s[A-Z][a-z]+)*");
        Matcher matcher = pattern.matcher(text);
        switch(name){
            case "AfterPoint":
                AfterPoint(matcher,text);
                break;
            case "CapitalizedWord":
                CapitalizedWordHeuristic(matcher);
                break;
            case "TwoTimes":
                TwoTimes(matcher, text);
                break;
            default:
                System.out.println("Invalid heuristic name");
                System.out.println("Valid heuristics names are:");
                System.out.println("    -CapitalizedWord");
                System.out.println("    -AfterPoint");
                System.out.println("    -TwoTimes");
        }
        return candidates;
    }

    private static void AfterPoint (Matcher matcher,String text){
        while (matcher.find()) {
            int start = matcher.start();
            String candidate = (matcher.group());
            if (start >= 2 && text.charAt(start - 2) != '.') {
                candidates.add(candidate);
            }
        }
    }

    private static void CapitalizedWordHeuristic (Matcher matcher){
        while (matcher.find()) {
            candidates.add(matcher.group());
        }
    }
    
    private static void TwoTimes (Matcher matcher, String text){
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