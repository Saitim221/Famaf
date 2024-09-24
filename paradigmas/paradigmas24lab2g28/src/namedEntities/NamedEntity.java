package namedEntities;

import java.io.IOException;
import java.util.*;

import utils.DictionaryData;
import utils.JSONParser;

public class NamedEntity {
    private String entity;
    private String category;
    private List<String> topic;
    private String characteristic;

    public NamedEntity(String candidate) throws IOException {
        this.entity = candidate;
        JSONParser parser = new JSONParser();
        List<DictionaryData> dictionarylist = parser.parseJsonDictionaryData("src/data/dictionary.json");

        if (!isRecognizable(candidate, dictionarylist)) {
            this.category = "OTHER";
            this.topic = new ArrayList<>();
            this.topic.add("OTHER");
        }
            
    }

    private boolean isRecognizable(String candidate, List<DictionaryData> dictionarylist) {
        boolean recognizable = false;

        for (DictionaryData dictionaryData : dictionarylist) {
            for (String keyword : dictionaryData.getKeywords()) {
                if (Objects.equals(keyword, candidate)) {
                    recognizable = true;
                    this.category = dictionaryData.getCategory();
                    this.topic = List.copyOf(dictionaryData.getTopics());
                    this.entity = dictionaryData.getLabel();
                    
                }
            }
        }

        return recognizable;
    }

    public String getEntity() {
        return entity;
    }

    public String getCategory() {
        return category;
    }

    public List<String> getTopic() {
        return topic;
    }

    public void print() {
        System.out.println("Entity: " + entity);
        System.out.println("Category: " + category);
        System.out.println("Topic: " + topic);
    }
}

