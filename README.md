# UFC Fight Analysis

### Background

The Ultimate Fighting Championship (UFC) is the world's premier mixed martial arts (MMA) organization. Founded in 1993, the UFC is largely responsible for the growth of MMA and is now home to the world's best martial artists.

A UFC match involves two opposing athletes fighting over three rounds (five rounds for championship fights). There are three main ways an athlete can win a fight:

- **Submission** - Occurs when one opponent verbally submits or taps (e.g. rear naked choke).
- **Technical knockout (TKO)** - Occurs when the referee stops the fight because they have determined the fighter can no longer defend themselves (e.g. punch to the face).
- **Judges score card** - Occurs when the fight lasts for all scheduled rounds. A panel of three judges scores the fight using a 10 point system. The figher with more points is deemed the winner of the fight.

*Note there are several other possible ways to win including "technical decision", "disqualification", "forefeit". However these situations are uncommon.*

### Is the UFC Fair?

The UFC is a relatively new sport, and the rules are still evolving. One common source of controversy is the outcome of the fight when it goes to the judges score card. UFC personalities and fighters often take to the web after fights to complain about poor juding decisions. The Bleacher Report wrote an article in 2014 highlight [The 10 Most Controversial Judging Decisions in UFC History](https://bleacherreport.com/articles/2072171-the-10-most-controversial-judging-decisions-in-ufc-history#slide0).

So how do judges score a fight? The system is somewhat confusing, but here are the basics:

- Judges score each round on a "*10-Point Must Sytem*".

- The fighter deemed to have won the round receives 10 points.

- The fighter deemed to have lost the round receives 9 points or fewer.

- The figher with the most points at the end of the fight wins.

- The [official MMA rules](http://www.abcboxing.com/wp-content/uploads/2016/08/juding_criteriascoring_rev0816.pdf) describe scoring as follows:

  > - "*A 10 –10 round in MMA is when both fighters have competed for whatever duration of time in the round and there is no difference or advantage between either fighter.*”
  > - “*A 10 –9 Round in MMA is where one combatant wins the round by a close margin.*”
  > - ""*A 10 –8 Round in MMA is where one fighter wins the round by a largemargin.*"

Based on a reading of the rules and general concensus from MMA personalities, it is clear that judging is very subjective. Our analysis seeks to understand if judging is fair.

### Research Question

**For fights that do not end in submission or TKO, what are the strongest predictors of who will win the fight?**

By answer the stated research question we hope to gain more insight into the fairness of UFC judging. Some possible outcomes of the analysis may be:

1. Several predictors were identified as strongly correlating to victory by decision. The judges consitnetly award a fighter for performing well in these areas. This would suggest that UFC judging is fair.

   > Example:
   >
   > A fight...

2. No strong predictors were identified. The judges do no consistnely score fights based on the available predictors. This would suggest that UFC judging is not fair.

   > Example:
   >
   > A fight...

### Data Description 

<>

### Proposed Research Plan

- key is interprebility
- we do not want black box model, b/c then we cannot see if consistnet
- Logistic regression classifier could be a good option?



## Reference

#### Useful Articles

- MMA judging criteria: http://www.abcboxing.com/wp-content/uploads/2016/08/juding_criteriascoring_rev0816.pdf
- MMA training criteria: http://www.abcboxing.com/MMA_REFEREE_AND_JUDGE_TRAINING_OUTLINE.pdf
- MMA "fouls": http://www.abcboxing.com/wp-content/uploads/2015/09/unified_rules_fouls_rev0816.pdf

#### Data

The original data was obtained from Kaggle user [Rajeev Warrier](https://www.kaggle.com/rajeevw) and can be found here:

https://www.kaggle.com/rajeevw

The data has also been downloaded and uploaded to a GitHub repo to avoid issues for users whom do not have a kaggle account:

https://github.com/SamEdwardes/ufc-data