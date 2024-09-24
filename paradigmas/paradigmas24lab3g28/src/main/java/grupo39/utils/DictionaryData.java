package grupo39.utils;

import java.util.List;

public class DictionaryData {

    private String label;
    private String category;
    private List<String> topics;

    private List<String> keywords;

    public DictionaryData(String label, String category, List<String> topics, List<String> keywords) {
        this.label = label;
        this.category = category;
        this.topics = List.copyOf(topics);
        this.keywords = List.copyOf(keywords);
    }

    public String getLabel() {
        return label;
    }

    public String getCategory() {
        return category;
    }

    public List<String> getTopics() {
        return topics;
    }

    public List<String> getKeywords() {
        return keywords;
    }

    public void print() {
        System.out.println("Entity: " + label);
        System.out.println("Category: " + category);
        System.out.println("Topic: " + topics);
        System.out.println("Keywords: " + keywords);
    }

}
