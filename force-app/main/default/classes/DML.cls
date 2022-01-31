/**
 * @author Afia Shams
 * @email afia.shams@mtxb2b.com
 * @desc To perform all DML operations
 */
public with sharing class DML {
    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform insert of single sObject
     */
    public static SObject doInsert( SObject sObj ) {
        if ( !sObj.getSObjectType().getDescribe().isCreateable() ) {
            throw new EEC_CustomException('Insufficient create access. ( Object: '+sObj.getSObjectType() +' )' );
        }
            
        insert sObj;
        return sObj;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform insert of list of sObject
     */
    public static List<SObject> doInsert( List<SObject> sObjs ) {
        if ( !sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isCreateable() ) {
            throw new EEC_CustomException('Insufficient create access. ( Object: '+sObjs[0].getSObjectType() +' )' );
        }

        insert sObjs;
        return sObjs;
    }
     
    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform insert of list of sObject with options
     */
    public static List<SObject> doInsert( List<SObject> sObjs, Database.DMLOptions dml ) {
        if ( !sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isCreateable() ) {
            throw new EEC_CustomException('Insufficient create access. ( Object: '+sObjs[0].getSObjectType() +' )' );
        }
		
        Database.insert( sObjs, dml );
        return sObjs;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform update of single sObject
     */
    public static SObject doUpdate( SObject sObj ) {
        if ( !sObj.getSObjectType().getDescribe().isUpdateable() ) {
            throw new EEC_CustomException('Insufficient update access. ( Object: '+sObj.getSObjectType() +' )' );
        }

        update sObj;
        return sObj;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform update of list of sObject
     */
    public static List<SObject> doUpdate( List<SObject> sObjs ) {
        if ( !sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isUpdateable() ) {
            throw new EEC_CustomException('Insufficient update access. ( Object: '+sObjs[0].getSObjectType() +' )' );
        }

        update sObjs;
        return sObjs;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform delete on single sObject
     */
    public static void doDelete( SObject sObj ) {
        if ( !sObj.getSObjectType().getDescribe().isDeletable() ) {
            throw new EEC_CustomException('Insufficient delete access. ( Object: '+sObj.getSObjectType() +' )' );
        }

        delete sObj;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform delete on list of sObject
     */
    public static void doDelete( List<SObject> sObjs ) {
        if ( !sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isDeletable() ) {
            throw new EEC_CustomException('Insufficient delete access. ( Object: '+sObjs[0].getSObjectType() +' )' );
        }

        delete sObjs;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform upsert of single sObject
     */
    public static void doUpsert( SObject sObj) {
        if ( !sObj.getSObjectType().getDescribe().isUpdateable() || !sObj.getSObjectType().getDescribe().isCreateable() ) {
            throw new EEC_CustomException('Insufficient create/update access. ( Object: '+sObj.getSObjectType() +' )' );
        }

        upsert sObj;
    }

    /**
     * @author Afia Shams
     * @email afia.shams@mtxb2b.com
     * @desc To perform upsert of list of sObject
     */
    public static void doUpsert( List<SObject> sObjs) {
        if (  !sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isCreateable() ||
              !sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isUpdateable() 
            ) {
            throw new EEC_CustomException('Insufficient create/update access. ( Object: '+sObjs[0].getSObjectType() +' )' );
        }

        upsert sObjs;
    }
    public class EEC_CustomException extends Exception{}
}