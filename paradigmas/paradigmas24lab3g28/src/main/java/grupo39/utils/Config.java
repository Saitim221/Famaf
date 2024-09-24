package grupo39.utils;

public class Config {

    private boolean printFeed = false;
    private boolean computeNamedEntities = false;
    private boolean printHelp = false;
    private String feedKey;
    private String nameEntityKey;
    private String statsFormatKey;
    // TODO: A reference to the used heuristic will be needed here

    public Config(boolean printFeed, boolean computeNamedEntities, boolean help, String feedKey, String nameEntityKey, String statsFormatKey) {
        this.printFeed = printFeed;
        this.printHelp = help;
        this.computeNamedEntities = computeNamedEntities;
        this.feedKey = feedKey;
        this.nameEntityKey = nameEntityKey;
        this.statsFormatKey = statsFormatKey;
    }

    public boolean getPrintFeed() {
        return printFeed;
    }

    //nuevo devuleve le printHelp
    public boolean getPrintHelp() {
        return printHelp;
    }

    public boolean getComputeNamedEntities() {
        return computeNamedEntities;
    }

    public String getFeedKey() {
        return feedKey;
    }

    public String getNameEntityKey() {
        return nameEntityKey;
    }

    public String getStatsFormatKey() {
        return statsFormatKey;
    }

}
